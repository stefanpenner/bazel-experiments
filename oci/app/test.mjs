import test from "node:test";
import assert from "node:assert";
import http from "node:http";
import { once } from "node:events";
import handler from "./handler.mjs";

const PORT = 9999;
const OTHER_PORT = 9998;

let mainServer;
let otherServer;

async function startOtherService() {
  const server = http.createServer((req, res) => {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(
      JSON.stringify({
        upstream: "other-service",
        path: req.url,
      }),
    );
  });

  server.listen(OTHER_PORT, "127.0.0.1");
  await once(server, "listening");
  return server;
}

async function startMainService() {
  const server = http.createServer((req, res) => {
    process.env.PORT = PORT.toString();
    process.env.SERVICE_NAME = "app-main";
    process.env.SERVICE_URL = `http://127.0.0.1:${PORT}`;
    process.env.OTHER_SERVICE_URL = `http://127.0.0.1:${OTHER_PORT}/info`;
    handler(req, res);
  });

  server.listen(PORT, "127.0.0.1");
  await once(server, "listening");
  return server;
}

async function fetchJson(pathname) {
  return new Promise((resolve, reject) => {
    http
      .get({ hostname: "127.0.0.1", port: PORT, path: pathname }, (res) => {
        let data = "";
        res.on("data", (chunk) => {
          data += chunk;
        });
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (err) {
            reject(err);
          }
        });
      })
      .on("error", reject);
  });
}

test.before(async () => {
  otherServer = await startOtherService();
  mainServer = await startMainService();
});

test.after(() => {
  mainServer?.close();
  otherServer?.close();
});

test("GET / returns default handler response", async () => {
  const body = await fetchJson("/");

  assert.strictEqual(body.url, "/");
  assert.strictEqual(body.method, "GET");
  assert.match(body.message, /Hello, World!/);
});

test("GET /self returns service metadata", async () => {
  const body = await fetchJson("/self");

  assert.deepStrictEqual(body, {
    name: "app-main",
    port: PORT.toString(),
    url: `http://127.0.0.1:${PORT}`,
  });
});

test("GET /other proxies to configured service", async () => {
  const body = await fetchJson("/other");

  assert.deepStrictEqual(body, {
    upstream: "other-service",
    path: "/info",
  });
});
