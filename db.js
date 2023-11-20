import dotenv from "dotenv";
import mysqlPromise from "mysql2/promise";

dotenv.config();

// connect to MySQL
const db = await mysqlPromise.createPool({
  host: process.env.MYSQL_HOST,
  port: process.env.MYSQL_PORT,
  database: process.env.MYSQL_DATABASE,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

export async function testConnection() {
  const [res] = await db.query(
    `
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
    `,
    []
  );

  return res;
}
