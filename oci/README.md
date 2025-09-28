### Notes

- needs docker: >= 4.34
- needs: host-networking enabled: go to Docker Desktop Settings > Resources > Network, select Enable host networking, and then restart Docker Desktop

run `bazel run //app:deploy` and then `curl 0.0.0.0:8080` to see
