DROP PROCEDURE IF EXISTS check_payment_common_logic;
DROP PROCEDURE IF EXISTS check_and_update_customer_status;
DROP PROCEDURE IF EXISTS update_bolts;
DROP FUNCTION IF EXISTS get_order_amount;
DROP FUNCTION IF EXISTS get_number_bolt;
DROP PROCEDURE IF EXISTS update_category_count;
DROP PROCEDURE IF EXISTS get_orders_from_supplier;
DROP PROCEDURE IF EXISTS update_category_price_percentage;
DROP PROCEDURE IF EXISTS get_supplier_payments;
DROP PROCEDURE IF EXISTS sort_suppliers_by_category_count;

DELIMITER //
-- Calculate the price of each order
CREATE FUNCTION get_order_amount(orderCode INT) RETURNS DECIMAL(10, 2) READS SQL DATA
BEGIN
    DECLARE orderAmount DECIMAL(10, 2);

    SELECT COALESCE(SUM(ccp.price * b.bolt_length), 0) INTO orderAmount
    FROM customer_order co
    JOIN bolt b ON co.order_code = b.order_code
    JOIN (
        SELECT cat_code, MAX(p_date) AS latest_date
        FROM category_current_price
        GROUP BY cat_code
    ) latest_prices ON b.cat_code = latest_prices.cat_code
    JOIN category_current_price ccp ON (latest_prices.cat_code = ccp.cat_code AND latest_prices.latest_date = ccp.p_date)
    WHERE co.order_code = orderCode;

    RETURN orderAmount;
END //

-- Calcuate the number of bolt in an order 
CREATE FUNCTION get_number_bolt(orderCode INT) RETURNS INT READS SQL DATA
BEGIN
    DECLARE number_bolt INT;

    SELECT COALESCE(COUNT(*),0) INTO number_bolt
    FROM bolt
	WHERE order_code = orderCode
	GROUP BY order_code;

    RETURN number_bolt;
END //

-- Calculate the number of bolt of each category
CREATE PROCEDURE update_category_count()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_cat_code INT;
    DECLARE new_quantity INT;

    -- Loop through each bolt in the order
    DECLARE cur CURSOR FOR
        SELECT cat_code AS temp_cat_code, COUNT(*) AS new_quantity
        FROM bolt
        WHERE order_code IS NULL
        GROUP BY cat_code;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO temp_cat_code, new_quantity;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update the quantity of bolts in the category
        UPDATE category
        SET quantity = new_quantity
        WHERE cat_code = temp_cat_code;
    END LOOP;

    CLOSE cur;
END //

-- Check for the payment date, customers' arrearage and order status
CREATE PROCEDURE check_payment_common_logic(
    IN order_code_param INT,
    IN payment_amount DECIMAL(10, 2),
    IN payment_date DATETIME,
    IN customer_code_param INT
)
BEGIN
    DECLARE order_amount DECIMAL(10, 2);
    DECLARE order_date DATE;
    DECLARE remaining_amount DECIMAL(10, 2);

    -- Get the total order amount, order date, and remaining price
    SELECT price, process_datetime, remaining_price
    INTO order_amount, order_date, remaining_amount
    FROM customer_order
    WHERE order_code = order_code_param;

    -- Check if payment amount is greater than order amount
    IF payment_amount > order_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment amount cannot exceed order amount';
    END IF;

    -- Check if payment date is earlier than order date
    IF payment_date < order_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Payment date cannot be earlier than order date';
    END IF;

    -- Deduct the payment amount from the customer's arrearage
    UPDATE customer
    SET arrearage_amount = GREATEST(0, arrearage_amount - payment_amount)
    WHERE customer_code = customer_code_param;

    -- Update remaining price
    SET remaining_amount = GREATEST(0, remaining_amount - payment_amount);

    -- Update the status of the order based on remaining price
    IF remaining_amount = 0 THEN
        -- Fully paid
        UPDATE customer_order
        SET status = 'full paid', remaining_price = remaining_amount
        WHERE order_code = order_code_param;
    ELSE
        -- Partial paid
        UPDATE customer_order
        SET status = 'partial paid', remaining_price = remaining_amount
        WHERE order_code = order_code_param;
    END IF;
END //

-- Update the "bad debt" status for customer
CREATE PROCEDURE check_and_update_customer_status()
BEGIN
    DECLARE customer_code_var INT;
    DECLARE warning_time_var TIMESTAMP;
    DECLARE current_time_var TIMESTAMP;
    DECLARE done BOOLEAN DEFAULT FALSE;

    -- Cursor to iterate through customers
    DECLARE customer_cursor CURSOR FOR
        SELECT customer_code, warning_time
        FROM customer
        WHERE warning_time IS NOT NULL;

    -- Declare handler for cursor not found
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET done = TRUE;

    OPEN customer_cursor;

    read_loop: LOOP
        FETCH customer_cursor INTO customer_code_var, warning_time_var;

        -- Exit the loop if no more rows
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calculate the difference in months
        SET current_time_var = CURRENT_TIMESTAMP;
        SET @months_difference = TIMESTAMPDIFF(MONTH, warning_time_var, current_time_var);

        -- Update customer status if warning time exceeds 6 months
        IF @months_difference > 6 THEN
            UPDATE customer
            SET debt_mode = 'bad debt'
            WHERE customer_code = customer_code_var;
        END IF;
    END LOOP;

    CLOSE customer_cursor;
END //

-- Increase a category selling price by a percentage of those provided by all suppliers from a specific date
CREATE PROCEDURE update_category_price_percentage(
    IN category_name_param VARCHAR(255),
    IN percentage DECIMAL(5, 2),
    IN effective_date_param DATE
)
BEGIN
    DECLARE cat_code_var INT;

    -- Get the category code based on the provided category name
    SELECT cat_code INTO cat_code_var
    FROM category
    WHERE cat_name = category_name_param;

    -- Check if the category exists
    IF cat_code_var IS NOT NULL THEN
        -- Update the selling price of the specified category by the given percentage
        UPDATE category_current_price
        SET price = price * (1 + percentage / 100)
        WHERE cat_code = cat_code_var AND p_date >= effective_date_param;
    END IF;
END //

-- Select all orders containing bolt from the supplier with input name
CREATE PROCEDURE get_orders_from_supplier(IN supplierName VARCHAR(255))
BEGIN
    SELECT co.*
    FROM customer_order co
    JOIN (
        SELECT DISTINCT co.order_code
        FROM customer_order co
        JOIN bolt b ON co.order_code = b.order_code
        JOIN category c1 ON c1.cat_code = b.cat_code
        LEFT JOIN category c2 ON c1.cat_name = c2.cat_name AND c2.in_order = TRUE
        JOIN supply s ON c2.cat_code = s.cat_code
        JOIN supplier sup ON s.sup_code = sup.sup_code
        WHERE sup.sup_name = supplierName
    ) AS distinct_orders
    ON co.order_code = distinct_orders.order_code;
END //

--  Calculate the total purchase price the agency has to pay for each supplier (since the output is "list of payment,
--  I will not put SUM to the purchase_price. 
CREATE PROCEDURE get_supplier_payments(IN supplierCode INT)
BEGIN
    SELECT DISTINCT io.import_code, io.import_date, io.purchase_price
    FROM import_order io
    JOIN supply s ON io.import_code = s.import_code
    JOIN supplier sup ON s.sup_code = sup.sup_code
    WHERE s.sup_code = supplierCode;
END //

-- Sort the suppliers in increasing number of categories they provide in a period of time 
CREATE PROCEDURE sort_suppliers_by_category_count(
    IN startDate DATE,
    IN endDate DATE
)
BEGIN
    SELECT sup.sup_code, sup.sup_name, COUNT(DISTINCT c.cat_name, c.color) AS category_count
    FROM supplier sup
    LEFT JOIN supply sp ON sup.sup_code = sp.sup_code
    LEFT JOIN category c ON sp.cat_code = c.cat_code
    WHERE sp.import_code IN (
        SELECT io.import_code
        FROM import_order io
        WHERE io.import_date BETWEEN startDate AND endDate
    )
    GROUP BY sup.sup_code, sup.sup_name
    ORDER BY category_count ASC;
END //

DELIMITER ;
