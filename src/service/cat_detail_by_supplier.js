import database_pool from "../database_connection/database_pool.js";

export async function cat_detail_by_supplier(supplier_id) {
    try {
        var get_supplier_sql =
            `
            SELECT *
            FROM supplier
            WHERE sup_code = ?
            `;
        
        const [supplier_data] = await database_pool.query(
            get_supplier_sql,
            [supplier_id]
        );
        var cat_list_sql =
            `
                CALL GetCategoryDetailsBySupplier(?)
            `;
        
        const [cat_res] = await database_pool.query(
            cat_list_sql,
            [supplier_id]
        );
        console.log(cat_res)
        const cat_list = cat_res[0]
        return { supplier_data, cat_list };
    }
    catch (err) { 
        console.log(err);
        return undefined;
    }
    
}
    
