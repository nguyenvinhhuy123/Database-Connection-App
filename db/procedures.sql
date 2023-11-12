DROP PROCEDURE IF EXISTS check_payment_common_logic;
DROP PROCEDURE IF EXISTS check_and_update_customer_status;
DROP FUNCTION IF EXISTS get_order_amount;
DROP FUNCTION IF EXISTS get_number_bolt;

DELIMITER //
-- Calculate the price of each order
CREATE FUNCTION get_order_amount(orderCode INT) RETURNS DECIMAL(10, 2) READS SQL DATA
BEGIN
    DECLARE orderAmount DECIMAL(10, 2);

    SELECT COALESCE(SUM(ccp.price), 0) INTO orderAmount
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
        SET status = 'Full Paid', remaining_price = remaining_amount
        WHERE order_code = order_code_param;
    ELSE
        -- Partial paid
        UPDATE customer_order
        SET status = 'Partial Paid', remaining_price = remaining_amount
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
            SET debt_mode = 'bad_debt'
            WHERE customer_code = customer_code_var;
        END IF;
    END LOOP;

    CLOSE customer_cursor;
END //
DELIMITER ;
