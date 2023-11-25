-- Insert data into the 'manager' table
INSERT INTO manager (fname, lname, gender, address, phone_number)
VALUES
('John', 'Doe', 'Male', '123 Main St', '1234567890'),
('Jane', 'Smith', 'Female', '456 Oak St', '9876543210'),
('David', 'Johnson', 'Male', '789 Elm St', '1112223333'),
('Emma', 'Davis', 'Female', '321 Pine St', '4445556666'),
('Robert', 'Brown', 'Male', '567 Birch St', '7778889999');

-- Insert data into the 'partner_staff' table
INSERT INTO partner_staff (fname, lname, gender, address, phone_number)
VALUES
('Mark', 'Johnson', 'Male', '789 Elm St', '5551234567'),
('Alice', 'Williams', 'Female', '321 Pine St', '8887654321'),
('Daniel', 'Taylor', 'Male', '987 Cedar St', '3334445555'),
('Olivia', 'Miller', 'Female', '654 Birch St', '6667778888'),
('James', 'Clark', 'Male', '876 Pine St', '9990001111');

-- Insert data into the 'operational_staff' table
INSERT INTO operational_staff (fname, lname, gender, address, phone_number)
VALUES
('Michael', 'Brown', 'Male', '567 Birch St', '1112223333'),
('Sara', 'Miller', 'Female', '987 Cedar St', '4445556666'),
('Ethan', 'Davis', 'Male', '345 Oak St', '7778889999'),
('Sophia', 'Smith', 'Female', '789 Elm St', '6665554444');

-- Insert data into the 'office_staff' table
INSERT INTO office_staff (fname, lname, gender, address, phone_number)
VALUES
('Chris', 'Lee', 'Male', '234 Oak St', '7778889999'),
('Emily', 'Clark', 'Female', '876 Pine St', '6664443333'),
('Mia', 'Johnson', 'Female', '345 Cedar St', '9991112222'),
('Noah', 'Williams', 'Male', '543 Elm St', '2223334444'),
('Ava', 'Brown', 'Female', '876 Birch St', '1110008888');

-- Insert data into the 'supplier' table
INSERT INTO supplier (sup_name, address, bank_account, tax_code, partner_code)
VALUES
('Fabric World', '789 Fabric Street, Textile City, State', '123456789012', '9876543210', 1),
('Textile Emporium', '456 Textile Avenue, Fabrictown, State', '456789012345', '1234567890', 2),
('Silk Haven', '321 Silk Lane, Materialville, State', '789012345678', '3456789012', 3),
('Silk Agency', '876 Poly Street, Synthetictown, State', '890123456789', '6789012345', 4),
('Master Bolt', '589 Golden Street, Synthetictown, State', '521123445996', '1234512345', 5);

-- Insert data into the 'supplier_phone' table
INSERT INTO supplier_phone (sup_code, phone_number)
VALUES
(1, '1234567890'),
(1, '2345678901'),
(2, '3456789012'),
(2, '4567890123'),
(3, '5678901234'),
(3, '6789012345'),
(4, '7890123456'),
(4, '8901234567'),
(5, '2456235124'),
(5, '7892354246');

-- Insert data into the 'customer' table
INSERT INTO customer (first_name, last_name, address, arrearage_amount, warning_time, debt_mode, office_code)
VALUES
('Alice', 'Johnson', '123 Maple St, Apt 45, Cityville, State', 0, NULL, NULL, 1),
('Bob', 'Smith', '456 Oak Lane, Suite 12, Townsville, State', 0, NULL, NULL, 2),
('Charlie', 'Davis', '789 Pine Avenue, Unit 8, Villagetown, State', 0, NULL, NULL, 3),
('David', 'Miller', '987 Elm Street, Floor 3, Hamletville, State', 0, NULL, NULL, 4),
('Eva', 'Clark', '654 Birch Blvd, Apartment 23, Hamletsville, State', 0, NULL, NULL, 5);

-- Insert data into the 'customer_phone' table
INSERT INTO customer_phone (customer_code, phone_number)
VALUES
(1, '1234567890'),
(1, '2345678901'),
(2, '3456789012'),
(2, '4567890123'),
(3, '5678901234'),
(3, '6789012345'),
(4, '7890123456'),
(4, '8901234567'),
(5, '9012345678'),
(5, '0123456789');

-- Insert data into the 'category' table
INSERT INTO category (cat_name, quantity, color, in_order)
VALUES
('Silk', 1, 'Red', true),
('Silk', 2, 'Red', true),
('Khaki', 1, 'Green', true),
('Crewel', 2, 'Blue', true),
('Crewel', 1, 'Blue', true),
('Jacquard', 3, 'Pink', true),
('Faux Silk', 2, 'Purple', true),
('Damask', 1, 'Yellow', true),
('Silk', 3, 'Red', false),
('Khaki', 1, 'Green', false),
('Crewel', 3, 'Blue', false),
('Jacquard', 3, 'Pink', false),
('Faux Silk', 2, 'Purple', false),
('Damask', 1, 'Yellow', false);

-- Insert data into the 'category_current_price' table
INSERT INTO category_current_price (cat_code, p_date, price)
VALUES
(9, '2023-10-28', 10.99),
(10, '2023-10-28', 15.99),
(11, '2023-10-28', 20.99),
(12, '2023-10-28', 12.99),
(13, '2023-10-28', 17.99),
(14, '2023-10-28', 19.99),
(9, '2023-10-29', 25.99),
(10, '2023-10-29', 30.99),
(11, '2023-10-29', 12.99),
(12, '2023-10-29', 20.99),
(13, '2023-10-29', 25.99),
(14, '2023-10-29', 27.99),
(9, '2023-10-30', 17.99),
(10, '2023-10-30', 22.99),
(11, '2023-10-30', 27.99),
(12, '2023-10-30', 26.99),
(13, '2023-10-30', 20.99),
(14, '2023-10-30', 23.99);

-- Insert data into the 'import_order' table
INSERT INTO import_order (purchase_price, import_date)
VALUES
(100.00, '2023-10-28'),	
(150.00, '2023-10-28'),
(220.00, '2023-10-28'),
(260.00, '2023-10-28'),
(230.00, '2020-08-28'),
(100.00, '2023-10-28'),
(170.00, '2023-10-28');

-- Insert data into the 'supply' table
INSERT INTO supply (import_code, cat_code, sup_code)
VALUES
(1, 7, 1),
(1, 8, 1),
(2, 3, 2),
(3, 4, 3),
(4, 5, 3),
(5, 1, 4),
(6, 2, 4),
(7, 6, 5);

-- Insert data into the 'customer_order' table
INSERT INTO customer_order (opcode, order_datetime, number_of_bolts, status, reason, process_datetime, customer_code)
VALUES
(1, '2023-11-11 12:15:00', 0, 'new', NULL, '2023-11-11 12:30:00', 1),
(1, '2023-11-01 12:15:00', 0, 'new', NULL, '2023-11-01 12:30:00', 1),
(2, '2023-11-08 16:15:00', 9, 'cancelled', 'Out of stock', '2023-11-08 16:20:00', 4),
(3, '2023-11-03 10:40:00', 0, 'new', NULL, '2023-11-03 10:45:00', 4),
(3, '2023-11-08 16:25:00', 3, 'cancelled', 'Out of stock', '2023-11-08 16:30:00', 4),
(4, '2023-11-02 09:25:00', 0, 'new', NULL, '2023-11-02 09:30:00', 5),
(4, '2023-11-02 08:05:00', 0, 'new', NULL, '2023-11-02 08:20:00', 5);

-- Insert data into the 'bolt' table
INSERT INTO bolt (cat_code, bolt_length, import_code, order_code)
VALUES
(9, 5.5, 6, 2),
(9, 4.5, 5, 2),
(9, 3, 5, NULL),
(10, 5, 2, 4),
(11, 8.5, 3, 4),
(11, 6.0, 4, NULL),
(11, 2, 4, NULL),
(12, 2.5, 7, 6),
(12, 6, 7, NULL), 
(12, 6.5, 7, NULL),
(13, 3, 1, NULL),
(13, 3.5, 1, 6),
(14, 4, 1, 6);

-- Update the status of some "new" orders to test the calculation of order price
UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 2;

UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 4;

UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 6;

-- Insert data into the 'paid_by_payment' table
INSERT INTO paid_by_payment (order_code, customer_code, pay_datetime, type, amount)
VALUES
(2, 1, '2023-11-01 13:30:00', 'Partial', 100),
(2, 1, '2023-11-01 14:45:00', 'Partial', 79.9),
(4, 4, '2023-11-03 12:15:00', 'Partial', 300),
(4, 4, '2023-11-03 14:30:00', 'Partial', 20.00);

UPDATE customer_order 
SET status = 'cancelled', reason = 'Do not want to buy'
WHERE order_code = 6;

INSERT INTO admin_account (user_account)
VALUES 
('myadmin');

