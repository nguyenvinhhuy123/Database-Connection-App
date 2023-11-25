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
DROP PROCEDURE IF EXISTS GetCategoryDetailsBySupplier;
DROP PROCEDURE IF EXISTS MaterialPurchasingInformation;
DROP PROCEDURE IF EXISTS GenerateOrderReport;

DELIMITER //
-- Calculate the price of each order
CREATE FUNCTION get_order_amount(orderCode INT) RETURNS DECIMAL(10, 2) READS SQL DATA
BEGIN
    DECLARE orderAmount DECIMAL(10, 2);

    SELECT COALESCE(SUM(CASE WHEN io.import_date >= '2020-09-01' AND c.cat_name = 'Silk' 
							THEN ccp.price * 1.1 * b.bolt_length 
                            ELSE ccp.price * b.bolt_length END), 0) INTO orderAmount
    FROM customer_order co
    JOIN bolt b ON co.order_code = b.order_code
    JOIN import_order io ON b.import_code = io.import_code
    JOIN category c ON b.cat_code = c.cat_code
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

-- List details of all categories which are provided by a supplier
CREATE PROCEDURE GetCategoryDetailsBySupplier(IN supplierCodeParam INT)
BEGIN
    SELECT DISTINCT c2.cat_code, c1.cat_name, c1.color, c2.quantity
    FROM category c1
    LEFT JOIN (
        SELECT * FROM category WHERE category.in_order = FALSE
    ) c2 ON c1.cat_name = c2.cat_name AND c1.color = c2.color
    JOIN supply sp ON c1.cat_code = sp.cat_code
    JOIN supplier s ON sp.sup_code = s.sup_code
    WHERE s.sup_code = supplierCodeParam;
END //

-- Search material purchasing information
CREATE PROCEDURE MaterialPurchasingInformation()
BEGIN
    SELECT 
        io.import_code, io.import_date, c.cat_name, c.color, c.quantity, 
        sup.sup_name, GROUP_CONCAT(sp.phone_number) AS supplier_phone, io.purchase_price AS total_order_price
    FROM import_order io
    JOIN supply s ON io.import_code = s.import_code
    JOIN category c ON s.cat_code = c.cat_code
    JOIN supplier sup ON s.sup_code = sup.sup_code
    LEFT JOIN supplier_phone sp ON sup.sup_code = sp.sup_code
    GROUP BY io.import_code, io.import_date, c.cat_name, c.color, c.quantity, sup.sup_name, io.purchase_price;
END //

-- Make a report that provides full information about the order for each category of a customer.
CREATE PROCEDURE GenerateOrderReport()
BEGIN
    SELECT 
        co.order_code, CONCAT(c.first_name, " ", c.last_name) AS customer_name, GROUP_CONCAT(cp.phone_number) AS customer_phone, 
        co.order_datetime, co.process_datetime, 
        cat_bolt.cat_name, cat_bolt.color, cat_bolt.bolt_count,
        co.price AS total_price, co.remaining_price AS debt_amount, co.status, co.reason, os.opcode, 
        CONCAT(os.fname, " ", os.lname) AS operator_name 
    FROM customer_order co
    JOIN customer c ON co.customer_code = c.customer_code
    LEFT JOIN 
        (SELECT cat.cat_code, cat.cat_name, cat.color, COUNT(DISTINCT b.bolt_code) AS bolt_count, b.order_code
        FROM bolt b
        JOIN category cat ON b.cat_code = cat.cat_code
        WHERE b.order_code IS NOT NULL
        GROUP BY cat.cat_code, cat.cat_name, cat.color, b.order_code) cat_bolt 
        ON cat_bolt.order_code = co.order_code
    LEFT JOIN customer_phone cp ON c.customer_code = cp.customer_code
    JOIN operational_staff os ON co.opcode = os.opcode
    GROUP BY 
        co.order_code, CONCAT(c.first_name, " ", c.last_name), co.process_datetime, co.order_datetime, 
        cat_bolt.cat_name, cat_bolt.color, cat_bolt.bolt_count, 
        co.price, co.remaining_price, co.status, co.reason, 
        os.opcode, CONCAT(os.fname, " ", os.lname);
        
	SELECT pp.order_code, c.customer_code, CONCAT(c.first_name, " ", c.last_name) AS customer_name, co.order_datetime, 
		pp.pay_datetime, pp.type, pp.amount
	FROM paid_by_payment pp
	JOIN customer c ON c.customer_code = pp.customer_code
	JOIN customer_order co ON co.order_code = pp.order_code;
END //

DELIMITER ;
