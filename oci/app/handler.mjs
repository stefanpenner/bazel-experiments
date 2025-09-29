export default function(req, res) {
  res.writeHead(200, { "content-type": "application/json" });
  res.end(`${new Date()} Hello, World!`);
}
