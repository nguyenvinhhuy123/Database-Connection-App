import database_pool from "../database_connection/database_pool.js";

export async function get_all_partner_id() { 
  try {
    const [partner_list] = await database_pool.query(
      `
      SELECT partner_code
      FROM partner_staff
      ORDER BY partner_code
      `,
    );
    const partner_id_list = []
    Object.keys(partner_list).forEach(
      function (key) { 
        const partner_id = partner_list[key].partner_code;
        partner_id_list.push(partner_id);
        console.log(partner_id);
      }
    )
    console.log(partner_id_list[1]);
    return partner_id_list;
  }
  catch (err) { 
    console.log(err);
    return undefined;
  }
}
export async function add_new_supplier(name, address, bank, tax, partner, phone) {
  console.log("Add start");
  try {
    var supplier_value = [name, address, bank, tax, partner]
    var supplier_id;

    var [check_phone] = await database_pool.query(
      `
        SELECT *
        FROM supplier_phone
        WHERE phone_number = ?
        `,
      phone
    );
    if (check_phone.length > 0) {
      throw new Error("Phone number existed already!!")
    }
    var insert_supplier_sql = `
        INSERT INTO supplier
        (sup_name, address, bank_account, tax_code, partner_code)
        VALUES ? 
      `
    const [add_supplier_successful] = await database_pool.query(
      insert_supplier_sql,
      [[supplier_value]]
    );
    console.log("Added supplier with ID :" + add_supplier_successful.insertId);
    supplier_id = add_supplier_successful.insertId;
    var add_phone_sql = `
        INSERT INTO supplier_phone
        (sup_code, phone_number)
        VALUES ?
      `
    const [add_phone_successful] = await database_pool.query(
      add_phone_sql,
      [[[supplier_id, phone]]]
    )
      
    console.log("Added supplier phone with ID :" + add_phone_successful.insertId);
    return true;
  }
  catch (err) {
    console.log(err);
    return false;
  }
  finally
  {
    return false;
  }
}
