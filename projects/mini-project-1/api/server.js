const express = require("express");
const os = require("os");

const app = express();
const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.json({
    message: "Hello from the container!",
    hostname: os.hostname(),
    env: process.env.NODE_ENV || "development",
  });
});

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.listen(PORT, () => console.log(`API listening on port ${PORT}`));
