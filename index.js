import express, { json } from "express";
import compression from "compression";
import bodyParser from "body-parser";

import { fileURLToPath } from "url";
import { dirname, sep } from "path";
import { testConnection } from "./db.js";

import { authentication } from "./src/service/auth.js";
import { add_new_supplier, get_all_partner_id } from "./src/service/add_supplier.js";
import { cat_detail_by_supplier } from "./src/service/cat_detail_by_supplier.js";

const __dirname = dirname(fileURLToPath(import.meta.url)) + sep;
const cfg = {
  port: process.env.PORT || 3000,
  dir: {
    root: __dirname,
    static: __dirname + "static" + sep,
    views: __dirname + "views" + sep,
  },
};
console.dir(cfg, { depth: null, color: true });

const app = express();
app.disable("x-powered-by");
app.use(bodyParser.urlencoded({ extended: true }));

app.set("view engine", "ejs");
app.set("views", cfg.dir.views);
app.use(compression());
app.use(express.static(cfg.dir.static));

var credential = false
app.get("/", (req, res) => {
  if (!credential) return res.redirect("/auth");
  return res.redirect("/home-page");
});
app.get("/log_out");
//Log out action
app.post("/log_out", (req, res) => {
  console.log("logged out");
  credential = false;
  res.redirect("/");
});

//auth action get method
app.get("/auth", (req, res) => {
  res.render("login/login");
});

// auth action post method: check for credential
app.post("/auth", async (req, res) => {
  var username = req.body.username;
  var password = req.body.password;
  if (!username || !password) {
    return res.render("login/login", {
      message: "Please enter both id and password",
    });
  } else {
    //! Subject to change: change after setting up database
    var auth_accepted = await authentication(username, password);
    if (auth_accepted) {
      credential = true;
      return res.redirect("/home-page");
    }
  }
  return res.render("login/login", {
    message: "Username or password incorrect",
  });
});

// 0. Home page route
app.get("/home-page", async (req, res) => {
  const data = await testConnection();
  res.render("message", {
    title: "Welcome to our database system assignment 2!",
    message: JSON.stringify(data),
  });
});

// 1. Search material purchasing information route
app.get("/search-material-purchasing/", (req, res) => {
  res.render("search_material_purchase", {
    title: "Search material purchasing information",
  });
});

//2. Add information for a new supplier.
app.get("/add_new_supplier/", async (req, res) => {
  const partner_id_list = await get_all_partner_id();
  res.render("add_new_supplier", {
    title: "Add information for a new supplier",
    id_list: partner_id_list
  });
});
app.post("/add_new_supplier/", async (req, res) => {
  var name = req.body.name;
  var address = req.body.address;
  var bank_id = req.body.bank;
  var tax_id = req.body.tax;
  var partner_id = req.body.partner;
  var phone_number = req.body.phone;
  if (!name || !address || !bank_id || !tax_id || !partner_id || !phone_number) {
    const partner_id_list = await get_all_partner_id();
    return res.render("add_new_supplier", {
      title: "Add information for a new supplier",
      id_list: partner_id_list,
      message: "Please enter all information",
      add_successful: false,
    });
  }
  console.log(name);
  var add_this_supplier = await add_new_supplier(
    name,
    address,
    bank_id,
    tax_id,
    partner_id,
    phone_number
  );

  if (!add_this_supplier) {
    const partner_id_list = await get_all_partner_id();
    return res.render("add_new_supplier", {
      title: "Add information for a new supplier",
      id_list: partner_id_list,
      message: "Please enter all information",
      add_successful: false,
    });
  }
  const partner_id_list = await get_all_partner_id();
  return res.render("add_new_supplier", {
      title: "Add information for a new supplier",
      id_list: partner_id_list,
      message: "Please enter all information",
      add_successful: false,
    });
});

//3. List details of all categories which are provided by a supplier.
app.get("/category_detail_by_supplier/", (req, res) => {
  res.render("category_detail_by_supplier", {
    title: "List details of all categories which are provided by a supplier",
  });
});

app.post("/category_detail_by_supplier/", async (req, res) => {
  var supplier_id = req.body.search_id;
  console.log(supplier_id);
  const { supplier_data, cat_list } = await cat_detail_by_supplier(supplier_id);
  console.log(supplier_data);
  console.log(cat_list.length);
  if (!supplier_data || supplier_data.length == 0) { 
    return res.render("category_detail_by_supplier", {
    title: "Add information for a new supplier",
    message: "Can not find this supplier",
  });
  }
  if (!cat_list || cat_list.length == 0) { 
      console.log(cat_list.length);
      return res.render("category_detail_by_supplier", {
      title: "Add information for a new supplier",
      message: "This supplier does not have any supplied category",
      supplier_data: supplier_data
  });
  }
  return res.render("category_detail_by_supplier", {
    title: "Add information for a new supplier",  
    supplier_data: supplier_data,
    cat_list: cat_list
  });
});

// 4. Report full information about the order for each category of a customer.
app.get("/report-order-per-customer-category/", (req, res) => {
  res.render("report_order_per_customer_category", {
    title: "Report information about the order for each category of a customer",
  });
});

// 404 errors
app.use((req, res) => {
  res
    .status(404)
    .render("message", { title: "Not found", message: "Page Not found!" });
});

app.listen(cfg.port, () => {
  console.log(`Server listening at http://localhost:${cfg.port}`);
});

export { cfg, app };
