load("@io_bazel_rules_go//go:def.bzl", "go_library", "go_prefix", "go_test")

go_prefix("github.com/sr/operator")

go_library(
    name = "go_default_library",
    srcs = [
        "command.go",
        "handler.go",
        "invoker.go",
        "operator.go",
        "operator.pb.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//generator:go_default_library",
        "@com_github_golang_protobuf//proto:go_default_library",
        "@com_github_golang_protobuf//protoc-gen-go/descriptor:go_default_library",
        "@com_github_golang_protobuf//ptypes:go_default_library",
        "@com_github_golang_protobuf//ptypes/duration:go_default_library",
        "@com_github_kr_text//:go_default_library",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_x_net//context:go_default_library",
    ],
)

filegroup(
    name = "go_default_library_protos",
    srcs = ["operator.proto"],
    visibility = ["//visibility:public"],
)

go_test(
    name = "go_default_test",
    srcs = ["operator_test.go"],
    deps = [
        "//:go_default_library",
        "//hipchat:go_default_library",
        "//testing:go_default_library",
        "@com_github_dvsekhvalnov_jose2go//:go_default_library",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_x_net//context:go_default_library",
    ],
)
