const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

app.get("/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", db: "up" });
  } catch (err) {
    res.status(503).json({ status: "error", db: "down" });
  }
});

app.get("/notes", async (req, res) => {
  const { rows } = await pool.query("SELECT id, text, created_at FROM notes ORDER BY id");
  res.json(rows);
});

app.post("/notes", async (req, res) => {
  const { text } = req.body || {};
  if (!text) return res.status(400).json({ error: "text is required" });
  const { rows } = await pool.query(
    "INSERT INTO notes (text) VALUES ($1) RETURNING id, text, created_at",
    [text]
  );
  res.status(201).json(rows[0]);
});

// The database container can take a few seconds to accept connections.
// Retry instead of crashing, so the API does not depend on start order.
async function waitForDb(retries = 20) {
  for (let i = 1; i <= retries; i++) {
    try {
      await pool.query("SELECT 1");
      console.log("Database reachable");
      return;
    } catch (err) {
      console.log(`Waiting for database (${i}/${retries})...`);
      await new Promise((r) => setTimeout(r, 1500));
    }
  }
  console.error("Database unreachable, giving up");
  process.exit(1);
}

waitForDb().then(() => app.listen(PORT, () => console.log(`API listening on port ${PORT}`)));
