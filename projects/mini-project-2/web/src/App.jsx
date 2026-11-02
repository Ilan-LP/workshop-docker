// VITE_APP_NAME is injected at BUILD time (not at runtime).
// That is why the Dockerfile needs an ARG for it.
const appName = import.meta.env.VITE_APP_NAME || "unnamed-app";

export default function App() {
  return (
    <main style={{ fontFamily: "sans-serif", textAlign: "center", marginTop: "20vh" }}>
      <h1>🐳 Hello from {appName}</h1>
      <p>This page is served by nginx inside a container.</p>
    </main>
  );
}
