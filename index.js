import express from "express";
import compression from "compression";
import bodyParser from "body-parser";

import { fileURLToPath } from "url";
import { dirname, sep } from "path";
import { testConnection } from "./db.js";

import { authentication } from "./src/controller/auth.js";
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

app.get("/", (req, res) => {
  res.redirect("/auth");
});

//auth action get method
app.get("/auth", (req, res) => {
  res.render("login/login");
});

// autth action post method: check for credential
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
app.get("/add_new_supplier/", (req, res) => {
  res.render("add_new_supplier", {
    title: "Add information for a new supplier",
  });
});

//3. List details of all categories which are provided by a supplier.
app.get("/category_detail_by_supplier/", (req, res) => {
  res.render("category_detail_by_supplier", {
    title: "List details of all categories which are provided by a supplier",
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
