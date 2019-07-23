# Bash Automated Testing System.
# See: https://github.com/sstephenson/bats

package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "bats",
    srcs = ["libexec/bats"],
    deps = [
        ":bats_lib",
    ],
)

sh_library(
    name = "bats_lib",
    srcs = [
        "libexec/bats-exec-suite",
        "libexec/bats-exec-test",
        "libexec/bats-format-tap-stream",
        "libexec/bats-preprocess",
    ],
)
