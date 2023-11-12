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
('Silk Agency', '876 Poly Street, Synthetictown, State', '890123456789', '6789012345', 4);

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
(4, '8901234567');

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

-- Merge data into the 'category' table
INSERT INTO category (cat_name, quantity, color, in_order)
VALUES
('Silk', 1, 'Red', true),
('Silk', 2, 'Red', true),
('Khaki', 1, 'Green', true),
('Crewel', 2, 'Blue', true),
('Crewel', 1, 'Blue', true),
('Crewel', 1, 'Blue', true),  
('Silk', 3, 'Red', false),
('Khaki', 1, 'Green', false),
('Crewel', 4, 'Blue', false);

-- Insert data into the 'category_current_price' table
INSERT INTO category_current_price (cat_code, p_date, price)
VALUES
(7, '2023-10-28', 10.99),
(8, '2023-10-28', 15.99),
(9, '2023-10-28', 20.99),
(7, '2023-10-29', 25.99),
(8, '2023-10-29', 30.99),
(9, '2023-10-29', 12.99),
(7, '2023-10-30', 17.99),
(8, '2023-10-30', 22.99),
(9, '2023-10-30', 27.99);

-- Insert data into the 'import_order' table
INSERT INTO import_order (purchase_price, import_date)
VALUES
(50.00, '2023-11-01'),
(30.00, '2023-11-01'),
(40.00, '2023-11-01');

-- Insert data into the 'supply' table
INSERT INTO supply (import_code, cat_code, sup_code)
VALUES
(1, 1, 1),
(1, 5, 1),
(2, 2, 2),
(2, 4, 2),
(3, 3, 4),
(3, 6, 4);

-- Insert data into the 'customer_order' table
INSERT INTO customer_order (opcode, number_of_bolts, status, reason, process_datetime, customer_code)
VALUES
(1, 0, 'new', NULL, '2023-11-11 12:30:00', 1),
(1, 0, 'new', NULL, '2023-11-01 12:30:00', 1),
(2, 10, 'partial paid', NULL, '2023-11-10 14:45:00', 2),
(3, 8, 'full paid', NULL, '2023-11-09 10:00:00', 3),
(4, 9, 'cancelled', 'Out of stock', '2023-11-08 16:20:00', 4),
(4, 0, 'new', NULL, '2023-11-03 10:45:00', 4),
(4, 9, 'cancelled', 'Out of stock', '2023-11-08 16:20:00', 4),
(4, 0, 'new', NULL, '2023-11-02 09:30:00', 5),
(4, 0, 'new', NULL, '2023-11-02 08:20:00', 5);

-- Insert data into the 'bolt' table
INSERT INTO bolt (cat_code, bolt_length, order_code)
VALUES
(7, 5.5, 2),
(7, 4.5, 2),
(7, 3, NULL),
(8, 7.0, 6),
(9, 8.5, 6),
(9, 6.0, 6),
(9, 9.0, 8),
(9, 9.0, 8);

-- Update the status of some "new" orders to test the calculation of order price
UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 2;

UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 6;

UPDATE customer_order
SET status = 'ordered'
WHERE order_code = 8;

-- Insert data into the 'paid_by_payment' table
INSERT INTO paid_by_payment (order_code, customer_code, pay_datetime, type, amount)
VALUES
(2, 1, '2023-11-01 13:30:00', 'Partial', 27.99),
(2, 1, '2023-11-01 14:45:00', 'Partial', 27.99),
(6, 4, '2023-11-03 12:15:00', 'Partial', 10),
(6, 4, '2023-11-03 14:30:00', 'Partial', 68.97),
(8, 5, '2023-11-02 16:45:00', 'Full', 23.98);

