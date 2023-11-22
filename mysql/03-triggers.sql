DROP TRIGGER IF EXISTS check_payment_insert;
DROP TRIGGER IF EXISTS check_payment_update;
DROP TRIGGER IF EXISTS update_customer_order_and_arrearage;
DROP TRIGGER IF EXISTS before_insert_bolt;

DELIMITER //
-- Trigger for BEFORE INSERT to paid_by_payment
CREATE TRIGGER check_payment_insert
BEFORE INSERT ON paid_by_payment
FOR EACH ROW
BEGIN
    CALL check_payment_common_logic(NEW.order_code, NEW.amount, NEW.pay_datetime, NEW.customer_code);
END //

-- Trigger for BEFORE UPDATE to paid_by_payment
CREATE TRIGGER check_payment_update
BEFORE UPDATE ON paid_by_payment
FOR EACH ROW
BEGIN
    CALL check_payment_common_logic(NEW.order_code, NEW.amount, NEW.pay_datetime, NEW.customer_code);
END //

-- Trigger for BEFORE UPDATE on customer_order to update arrearage, price, number of bolts and warning time
CREATE TRIGGER update_customer_order_and_arrearage
BEFORE UPDATE ON customer_order
FOR EACH ROW
BEGIN
    DECLARE order_amount DECIMAL(10, 2);
	DECLARE customer_arrearage DECIMAL(10, 2);

    -- Get the order amount
    SELECT get_order_amount(NEW.order_code) INTO order_amount;

    -- If the order is ordered (finish ordering),recount the number of bolts in each category and also increase the arrearage
    IF OLD.status = 'new' AND NEW.status = 'ordered' THEN
        -- Update the customer's arrearage
        UPDATE customer
        SET arrearage_amount = arrearage_amount + order_amount
        WHERE customer_code = NEW.customer_code;
        
        SET NEW.price = get_order_amount(NEW.order_code), 
			NEW.remaining_price = get_order_amount(NEW.order_code),
            NEW.number_of_bolts = get_number_bolt(NEW.order_code);
		
        CALL update_category_count(); 
    END IF;
    
    -- If the order is cancelled, put the bolts back to the categories and also reduce the arrearage
    IF OLD.status = 'ordered' AND NEW.status = "cancelled" THEN 
		UPDATE customer
        SET arrearage_amount = arrearage_amount - order_amount
        WHERE customer_code = NEW.customer_code;
        
        SET NEW.price = 0, 
			NEW.remaining_price = 0,
            NEW.number_of_bolts = 0;
		
        UPDATE bolt
        SET order_code = NULL 
        WHERE bolt.order_code = NEW.order_code;
        CALL update_category_count(); 
    END IF;

    -- Get the customer's arrearage amount
    SELECT arrearage_amount INTO customer_arrearage
    FROM customer
    WHERE customer_code = NEW.customer_code;

    -- Update the customer's warning time based on arrearage
    -- Check if arrearage is over 2000
    IF customer_arrearage > 2000 THEN
        -- Update customer status to warning mode
        UPDATE customer
        SET warning_time = CURRENT_TIMESTAMP
        WHERE customer_code = NEW.customer_code;
    ELSE
        -- Set warning_time to NULL
        UPDATE customer
        SET warning_time = NULL, debt_mode = NULL
        WHERE customer_code = NEW.customer_code;
    END IF;
END //


-- Trigger for auto_increment the bolt id 
CREATE TRIGGER before_insert_bolt
BEFORE INSERT ON bolt 
FOR EACH ROW
BEGIN
    SET NEW.bolt_code = (SELECT COALESCE(MAX(bolt_code), 1) FROM bolt) + 1;
END // 

DELIMITER ;
