import database_pool from "../database_connection/database_pool.js";

export async function authentication(username, password) {
  try {
      const [database_result] = await database_pool.query(
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
      //* If there is a match username and password
      if (database_result.length > 0) return true;
      return false;
  }
  catch (err) { 
    console.log(err);
    return false;
  }
}

