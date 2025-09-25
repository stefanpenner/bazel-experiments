"""Custom Bazel rules for Docker helpers."""

def _docker_run_impl(ctx):
    script = ctx.actions.declare_file(ctx.label.name + "_runner.sh")

    image = ctx.attr.image
    context = ctx.attr.context
    dockerfile = ctx.attr.dockerfile
    run_args = " ".join(['"%s"' % arg for arg in ctx.attr.run_args])

    run_command = "docker run --rm {image}".format(image = image)
    if run_args:
        run_command = run_command + " " + run_args

    script_content = """#!/usr/bin/env bash
set -euo pipefail

cd "$BUILD_WORKSPACE_DIRECTORY"

docker build -t {image} -f {dockerfile} {context}
{run_command}
""".format(
        image = image,
        dockerfile = dockerfile,
        context = context,
        run_command = run_command,
    )

    ctx.actions.write(
        output = script,
        content = script_content,
        is_executable = True,
    )

    runfiles = ctx.runfiles()

    return DefaultInfo(
        executable = script,
        runfiles = runfiles,
    )

docker_run = rule(
    implementation = _docker_run_impl,
    attrs = {
        "context": attr.string(default = "docker"),
        "dockerfile": attr.string(default = "docker/Dockerfile"),
        "image": attr.string(default = "bazel-experiments/hello:latest"),
        "run_args": attr.string_list(default = []),
    },
    executable = True,
    doc = "Builds and runs a Docker image from the workspace root.",
)


