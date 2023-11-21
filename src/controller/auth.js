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

export async function authentication(username, password) {
  const [database_result] = await db.query(
    `
            SELECT
            *
            FROM
            admin_account ad
            WHERE user_account = ?
            AND user_password = ?
        `,
    [username, password]
  );
  if (database_result.length > 0) return true;
  else return false;
}
