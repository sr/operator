load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_binary")

go_library(
    name = "go_default_library",
    srcs = [
        "main.go",
        "template.go",
    ],
    visibility = ["//testing:__pkg__"],
    deps = ["//generator:go_default_library"],
)

go_binary(
    name = "protoc-gen-operatorlocal",
    library = ":go_default_library",
    visibility = ["//visibility:public"],
)
