import http from "node:http";
import https from "node:https";
import { URL } from "node:url";

function defaultHandler(req, res) {
  res.writeHead(200, { "content-type": "application/json" });
  res.end(
    JSON.stringify({
      message: `${new Date()} ${process.env.MESSAGE}`,
      url: req.url,
      method: req.method,
    }),
  );
}

function selfHandler(_req, res) {
  const name = process.env.SERVICE_NAME || "app";
  const port = process.env.PORT || "unknown";
  const url = process.env.SERVICE_URL || `http://0.0.0.0:${port}`;

  res.writeHead(200, { "content-type": "application/json" });
  res.end(
    JSON.stringify({
      name,
      port,
      url,
    }),
  );
}

function getClient(protocol) {
  if (protocol === "https:") {
    return https;
  }
  if (protocol === "http:") {
    return http;
  }
  throw new Error(`Unsupported protocol: ${protocol}`);
}

function proxyHandler(req, res) {
  const target = process.env.OTHER_SERVICE_URL;

  if (!target) {
    res.writeHead(500, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: "OTHER_SERVICE_URL is not set" }));
    return;
  }

  let url;
  try {
    url = new URL(target);
  } catch (err) {
    res.writeHead(500, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: `Invalid OTHER_SERVICE_URL: ${err.message}` }));
    return;
  }

  const client = getClient(url.protocol);

  const requestOptions = {
    protocol: url.protocol,
    hostname: url.hostname,
    port: url.port || (url.protocol === "https:" ? 443 : 80),
    path: url.pathname + url.search,
    method: req.method,
    headers: {
      ...req.headers,
      host: url.host,
    },
  };

  const proxyReq = client.request(requestOptions, (proxyRes) => {
    res.writeHead(proxyRes.statusCode ?? 502, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on("error", (error) => {
    res.writeHead(502, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: `Proxy request failed: ${error.message}` }));
  });

  req.pipe(proxyReq);
}

export default function handler(req, res) {
  if (req.url === "/other") {
    proxyHandler(req, res);
    return;
  }

  if (req.url === "/self") {
    selfHandler(req, res);
    return;
  }

  defaultHandler(req, res);
}
