import express from "express";
import compression from "compression";

import { fileURLToPath } from "url";
import { dirname, sep } from "path";

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

app.set("view engine", "ejs");
app.set("views", cfg.dir.views);
app.use(compression());
app.use(express.static(cfg.dir.static));

// 0. Home page route
app.get("/", (req, res) => {
  res.render("message", {
    title: "Welcome to our database system assignment 2!",
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
// 4. Report full information about the order for each category of a customer.
app.get("/report-order-per-customer-category/", (req, res) => {
  res.render("report_order_per_customer_category", {
    title: "Report information about the order for each category of a customer",
  });
});

app.get("/login/", (req, res) => {
  res.render("login/login");
});

// 404 errors
app.use((req, res) => {
  res.status(404).render("message", { title: "Not found" });
});

app.listen(cfg.port, () => {
  console.log(`Server listening at http://localhost:${cfg.port}`);
});

export { cfg, app };
