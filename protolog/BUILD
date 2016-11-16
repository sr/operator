load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "go_default_library",
    srcs = [
        "defaults.go",
        "delimited.go",
        "discard_pusher.go",
        "logger.go",
        "multi_pusher.go",
        "protolog.go",
        "text_marshaller.go",
        "write_pusher.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//protolog/pb:go_default_library",
        "@com_github_golang_protobuf//proto:go_default_library",
        "@com_github_golang_protobuf//ptypes:go_default_library",
        "@com_github_matttproud_golang_protobuf_extensions//pbutil:go_default_library",
        "@com_github_satori_go_uuid//:go_default_library",
    ],
)
