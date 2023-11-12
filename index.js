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

app.set('view engine', 'ejs');
app.set('views', cfg.dir.views);
app.use(compression());
app.use(express.static(cfg.dir.static));

// home page route
app.get('/', (req, res) => {
  res.render('message', { title: 'Hello World!' });
});

// another route
app.get('/hello/', (req, res) => {
  res.render('message', { title: 'Hello again!' });
});

app.get('/login/', (req, res) => {
    res.render('login/login');
});

// 404 errors
app.use((req, res) => {
  res.status(404).render('message', { title: 'Not found' });
});


app.listen(cfg.port, () => {
  console.log(`Server listening at http://localhost:${cfg.port}`);
});

export { cfg, app };
