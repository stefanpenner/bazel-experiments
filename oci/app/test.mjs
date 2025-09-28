import test from "node:test";
import assert from "node:assert";
import http from "node:http";
import { spawn } from "node:child_process";

const SERVER_PATH = new URL("./app.mjs", import.meta.url).pathname;
const PORT = 9999;

let child;

test("setup server", async () => {
  child = spawn("node", [SERVER_PATH], {
    env: { ...process.env, PORT: PORT.toString() },
    stdio: ["ignore", "pipe", "pipe"],
  });

  // Wait a bit for the server to start
  await new Promise(r => setTimeout(r, 500));
});

test("GET / returns JSON", async () => {
  const body = await new Promise((resolve, reject) => {
    http.get({ hostname: "127.0.0.1", port: PORT, path: "/" }, res => {
      let data = "";
      res.on("data", chunk => (data += chunk));
      res.on("end", () => resolve(data));
    }).on("error", reject);
  });

  const parsed = JSON.parse(body);
  assert.strictEqual(parsed.url, "/");
  assert.strictEqual(parsed.method, "GET");
});

test("GET /health returns ok", async () => {
  const body = await new Promise((resolve, reject) => {
    http.get({ hostname: "127.0.0.1", port: PORT, path: "/health" }, res => {
      let data = "";
      res.on("data", chunk => (data += chunk));
      res.on("end", () => resolve(data));
    }).on("error", reject);
  });

  assert.strictEqual(body, "ok");
});

test("teardown server", async () => {
  child.kill("SIGTERM");
});
