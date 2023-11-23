import dotenv from "dotenv";
import mysqlPromise from "mysql2/promise";

dotenv.config();

// connect to MySQL
var db = await mysqlPromise.createPool({
  host: process.env.MYSQL_HOST,
  port: process.env.MYSQL_PORT,
  database: process.env.MYSQL_DATABASE,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

export async function add_new_supplier(name, address, bank, tax, partner) {
  return false;
}
