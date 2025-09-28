import http from "node:http";

const PORT = Number(process.env.PORT) || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "content-type": "application/json" });
  res.end(`${new Date()} Hello, World!`);
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`listening on http://0.0.0.0:${PORT}`);
});

for (const sig of ["SIGINT", "SIGTERM"]) {
  process.on(sig, () => server.close(() => process.exit(0)));
}
