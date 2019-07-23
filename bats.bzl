# This file defines the `bats_test` rule.

def _run_bats_on_file(bats, f):
    """Return shell commands for testing file 'f' with 'bats'."""
    return """
echo Testing {path} ...
{bats} {path}
""".format(bats=bats.path, path=f.path)

def _impl(ctx):
    script = "\n".join(
        ["#!/usr/bin/env bash"] +
        ['set -eu'] +
        [_run_bats_on_file(ctx.files._bats[0], f) for f in ctx.files.srcs]
    )

    # Write the file, it is executed by 'bazel test'.
    ctx.actions.write(
        output = ctx.outputs.executable,
        content = script,
    )

    # To ensure the files needed by the script are available, we put them in
    # the runfiles.
    runfiles = ctx.files.srcs + ctx.files.deps + ctx.files._bats
    return [DefaultInfo(runfiles=ctx.runfiles(files=runfiles))]


bats_test = rule(
    implementation = _impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(allow_empty=False, allow_files=['.bats']),
        "deps": attr.label_list(),
        "_bats": attr.label(
             executable = True,
             cfg = "host",
             allow_files = True,
             default = Label("@com_github_sstephenson_bats//:bats"),
         ),
    },
)
