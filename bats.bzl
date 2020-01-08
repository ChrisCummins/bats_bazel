# This file defines the `bats_test` rule and `bats_deps`.
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")


def _run_bats_on_file(bats, f):
  """Return shell commands for testing file 'f' with 'bats'."""
  return """
echo Testing {path} ...
{bats} {path}
""".format(bats=bats.path, path=f.path)


def _impl(ctx):
  script = "\n".join(
      [
          "#!/usr/bin/env bash",
          "# Set working directory for bats from bazel test environment.",
          'if [[ -n "$TEST_TMPDIR" ]]; then',
          '  export TMPDIR="$TEST_TMPDIR"',
          "fi",
          "set -eu",
      ] + [
          _run_bats_on_file(ctx.files._bats[0], f) for f in ctx.files.srcs
      ])

  # Write the file, it is executed by 'bazel test'.
  ctx.actions.write(
      output=ctx.outputs.executable,
      content=script,
  )

  runfiles = ctx.runfiles(
      files=ctx.files._bats + ctx.files.srcs + ctx.files.data,
      # Collect transitive dependencies from src, data, and deps attributes.
      collect_default=True,
      collect_data=True,
  )
  return [DefaultInfo(runfiles=runfiles)]


bats_test = rule(
    implementation=_impl,
    test=True,
    attrs={
        "srcs":
        attr.label_list(allow_empty=False,
                        allow_files=['.bats'],
                        mandatory=True),
        "data":
        attr.label_list(allow_files=True),
        "_bats":
        attr.label(
            executable=True,
            cfg="host",
            allow_files=True,
            default=Label("@com_github_sstephenson_bats//:bats"),
        ),
    },
)


def bats_deps():
  http_archive(
      name="com_github_sstephenson_bats",
      build_file="@com_github_chriscummins_rules_bats//:bats.BUILD",
      sha256="80ca6a978a8cfe305d2dedd1de2fa9ac18e9594e7bf42ce6345697002e8420a5",
      strip_prefix="bats-03608115df2071fff4eaaff1605768c275e5f81f",
      url=
      "https://github.com/sstephenson/bats/archive/03608115df2071fff4eaaff1605768c275e5f81f.zip",
  )
