load("@io_bazel_rules_go//go:def.bzl", "go_library")

go_library(
    name = "go_default_library",
    srcs = [
        "protologpb.go",
        "protologpb.pb.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_golang_protobuf//proto:go_default_library",
        "@com_github_golang_protobuf//ptypes/timestamp:go_default_library",
    ],
)

filegroup(
    name = "go_default_library_protos",
    srcs = ["protologpb.proto"],
    visibility = ["//visibility:public"],
)
