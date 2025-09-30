### Requirements
- Docker Desktop >= 4.34
- Host networking enabled (Docker Desktop → Settings → Resources → Network → Enable host networking, then restart Docker)

### Deploy targets
- `bazel run //examples/simple-app:deploy` exposes the service on port 8080 with message "Hello, World!"
- `bazel run //examples/simple-app:deploy.alt` exposes the service on port 9090 with message "Goodnight!"

### Verifying
- `curl 0.0.0.0:8080` — default handler
- `curl 0.0.0.0:9090` — alternate handler
- `curl 0.0.0.0:8080/self` — metadata for the 8080 service
- `curl 0.0.0.0:9090/self` — metadata for the 9090 service
- `curl 0.0.0.0:8080/other` — proxies to the service on 9090 (uses `OTHER_SERVICE_URL`)
- `curl 0.0.0.0:9090/other` — proxies to the service on 8080