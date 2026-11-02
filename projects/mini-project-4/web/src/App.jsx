import { useEffect, useState } from "react";

// All requests go to /api/*. In production nginx forwards them to the "api"
// container, in dev Vite does the same (see vite.config.js).
export default function App() {
  const [notes, setNotes] = useState([]);
  const [text, setText] = useState("");
  const [error, setError] = useState(null);

  const load = () =>
    fetch("/api/notes")
      .then((r) => r.json())
      .then(setNotes)
      .catch(() => setError("Cannot reach the API"));

  useEffect(() => {
    load();
  }, []);

  const add = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    await fetch("/api/notes", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
    });
    setText("");
    load();
  };

  return (
    <main style={{ fontFamily: "sans-serif", maxWidth: 480, margin: "10vh auto" }}>
      <h1>🐳 Notes</h1>
      {error && <p style={{ color: "crimson" }}>{error}</p>}
      <form onSubmit={add} style={{ display: "flex", gap: 8 }}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="New note..."
          style={{ flex: 1, padding: 8 }}
        />
        <button type="submit">Add</button>
      </form>
      <ul>
        {notes.map((n) => (
          <li key={n.id}>{n.text}</li>
        ))}
      </ul>
    </main>
  );
}
