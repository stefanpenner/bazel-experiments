load("@rules_oci//oci:defs.bzl", "oci_load")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")

def _absolute(rel):
    """Pin a label to THIS repo, even when called from another repo.

    rel: string like "//tools:docker_run.sh" or "//tools:runner"
    """
    repo = native.repository_name()  # "@rules_deploy" or "@"
    return Label(rel if repo == "@" else repo + rel)

def deploy(name, image, repo_tag, container_env=None):
  """Deploys an OCI image and runs a Docker command.
\
  Args:
      name: The name of the top-level deploy target.
      image: The image to be loaded.
      repo_tag: The repository tag for the image.
      container_env: Optional dict of environment variables to pass to the container.
  """

  oci_load_target = name + "_load_oci"

  # 1. Load the OCI image
  oci_load(
    name = oci_load_target,
    image = image,
    repo_tags = [repo_tag],
    visibility = ["//visibility:private"],
  )

  # 2. Wrap the deployment logic in an sh_binary for use with `bazel run`.
  deploy_env = {k: str(v) for k, v in (container_env or {}).items()}
  deploy_port = deploy_env.get("PORT", "")

  sh_binary(
      name = name,
      srcs = [_absolute("//:deploy.sh")],
      data = [
        ":" + oci_load_target,
        "@bazel_tools//tools/bash/runfiles",
      ],
      env = {
          "DEPLOY_OCI_LOAD_EXECUTABLE": "$(location :{oci_load_target})".format(oci_load_target = oci_load_target),
          "DEPLOY_REPO_TAG": repo_tag,
          "DEPLOY_ENV_KEYS": " ".join(sorted(deploy_env.keys())) if deploy_env else "",
      } | deploy_env,
      visibility = ["//visibility:private"],
      tags = ["local", "no-remote", "requires-network"],
  )
