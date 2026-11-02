const http = require("http");
const os = require("os");

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
  res.end(
    JSON.stringify({
      message: "Hello from inside a container 🐳",
      hostname: os.hostname(),
      node: process.version,
      platform: `${os.platform()} ${os.arch()}`,
    })
  );
});

server.listen(PORT, () => console.log(`Demo server listening on ${PORT}`));
