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

export async function add_new_supplier(name, address, bank, tax, partner, phone) {
  try {
    var supplier_value = [name, address, bank, tax, partner]
    var supplier_id;
    var insert_supplier_sql = `
      INSERT INTO supplier
      (sup_name, address, bank_account, tax_code, partner_code)
      = ? 
    `
    const [add_supplier_successful] = await db.query(
      insert_supplier_sql,
      supplier_value,
      function (err, res) {
        if (err) throw err;
        console.log("Added supplier with ID :" + res.insertId);
        supplier_id = res.insertId;
      }
    );
    var add_phone_sql = `
      INSERT INTO supplier_phone
      (sup_code, phone_number)
      = ?
    `
    const [add_phone_successful] = await db.query(
      add_phone_sql,
      [supplier_id, phone],
      function (err, res) {
        if (err) throw err;
        console.log("Added supplier phone with ID :" + supplier_id);
      }
    )
    return true;
  }
  catch (err) { 
    console.log(err);
    return false;
  }
}
