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
  },
};
console.dir(cfg, { depth: null, color: true });

const app = express();
app.disable("x-powered-by");

app.use(compression());
app.use(express.static(cfg.dir.static));

app.get("/", (req, res) => {
  res.send("Hello World!");
});

app.use((req, res) => {
  res.status(404).send("Not found");
});

app.listen(cfg.port, () => {
  console.log(`Server listening at http://localhost:${cfg.port}`);
});

export { cfg, app };
