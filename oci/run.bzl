"""Custom run rules for the oci workspace."""

def _cli_run_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(
        output = output,
        target_file = ctx.executable.cli,
        is_executable = True,
    )

    cli_default = ctx.attr.cli[DefaultInfo]

    return [
        DefaultInfo(
            executable = output,
            runfiles = cli_default.default_runfiles,
        ),
    ]


cli_run = rule(
    implementation = _cli_run_impl,
    executable = True,
    attrs = {
        "cli": attr.label(
            executable = True,
            cfg = "target",
            providers = [DefaultInfo],
        ),
    },
)

