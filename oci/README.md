# Bazel OCI Deployment Demo

This project demonstrates a complete Bazel workflow for building, containerizing, and locally deploying multiple services. It showcases:
- Building multiple services with Bazel
- Packaging services as OCI containers
- Local deployment with `bazel run`
- Seamless inter-connectivity between host and containerized services
- Custom Bazel deployment macros for streamlined operations
- Automatic propagation: changes at any level (code, config, dependencies) are reflected across the entire build and deployment pipeline

See the [`examples/`](examples/) directory for working implementations.

### Requirements
- Docker Desktop >= 4.34
- Host networking enabled (Docker Desktop → Settings → Resources → Network → Enable host networking, then restart Docker)

### Deploy targets
- `bazel run //examples/simple-app:deploy` exposes the service on port 8001 with message "Hello, World!"
- `bazel run //examples/simple-app:deploy.alt` exposes the service on port 8002 with message "Goodnight!"
- `bazel run //examples/simple-app:deploy.back-to-host` exposes the service on port 8003 with message "back-to-host!"
- `PORT=8004 MESSAGE=real-host bazel run //examples/simple-app:app.bin` service running on the real host, with message "real-host"

### Verifying
- `curl 0.0.0.0:8001` — default handler(its /other connects to 8002)
- `curl 0.0.0.0:8002` — alternate handler (its /other connects to 8001)
- `curl 0.0.0.0:8003` — back-to-host handler (its /other connects to 8004)
- `curl 0.0.0.0:8004` — handler running only on host.
