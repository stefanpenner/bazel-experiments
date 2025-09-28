load("@rules_oci//oci:defs.bzl", "oci_load")

def deploy(name, image, repo_tag):
  """Deploys an OCI image and runs a Docker command.

  Args:
      name: The name of the top-level deploy target.
      image: The image to be loaded.
      repo_tag: The repository tag for the image.
  """

  oci_load_target = name + "_load_oci"
  docker_run_target = name + "_run_docker"

  # 1. Load the OCI image
  oci_load(
    name = oci_load_target,
    image = image,
    repo_tags = [repo_tag],
    visibility = ["//visibility:private"],
  )

  # 2. Run the docker command after the image is loaded.
  # We reference the OCI load target as a tool.
  native.genrule(
    name = name,
    outs = [name + ".out"],
    local = True,
    executable = True,
    cmd = """
        # Ensure image is loaded before attempting to run it.
        $(location :{oci_load_target})
        # Then, run the docker image and capture its output.
        docker run --rm {repo_tag} > $@
      """.format(
        oci_load_target = oci_load_target,
        repo_tag = repo_tag
      ),
      tools = [":" + oci_load_target],
      visibility = ["//visibility:private"],
  )
