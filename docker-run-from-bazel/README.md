## Minimal Docker example

This workspace includes a tiny Docker example under `docker/`:

- `docker/Dockerfile`: Alpine image that runs a small shell script
- `docker/hello.sh`: Prints a message

### Build

```bash
docker build -t bazel-experiments/hello:latest docker
```

### Run

```bash
docker run --rm bazel-experiments/hello:latest
```

### Bazel helper rule

You can build and run the image via Bazel:

```bash
bazel run //:hello_container
```

Expected output:

```text
Hello from Docker via Bazel experiments!
```



