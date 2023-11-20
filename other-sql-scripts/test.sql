-- Calculate the price of an order 
SELECT
    co.order_code, COALESCE(SUM(ccp.price), 0) AS order_amount
FROM
    customer_order co
JOIN
    bolt b ON co.order_code = b.order_code
JOIN
    (
        SELECT
            cat_code, MAX(p_date) AS latest_date
        FROM
            category_current_price
        GROUP BY
            cat_code
    ) latest_prices ON b.cat_code = latest_prices.cat_code
JOIN
    category_current_price ccp ON (latest_prices.cat_code = ccp.cat_code AND latest_prices.latest_date = ccp.p_date)
GROUP BY
    co.order_code;

SELECT get_order_amount("1001");

SELECT * FROM bolt;

SELECT * FROM customer;

SELECT * FROM customer_order;

SELECT * FROM paid_by_payment;
