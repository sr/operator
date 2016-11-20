load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")
load(":rules.bzl", "proto_gen", "go_lint")

go_binary(
    name = "operatorctl",
    srcs = [
        ":operatorctl_genproto",
    ],
    deps = [
        ":go_default_library",
        "//:go_default_library",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_x_net//context:go_default_library",
    ],
)

go_library(
    name = "go_default_library",
    srcs = [
        "testing.go",
        "testing.pb.go",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:go_default_library",
        "@com_github_golang_protobuf//proto:go_default_library",
        "@org_golang_google_grpc//:go_default_library",
        "@org_golang_x_net//context:go_default_library",
    ],
)

sh_test(
    name = "integration_test",
    size = "small",
    srcs = ["integration_test.sh"],
    data = [":operatorctl"],
)

go_lint(
    deps = [
        "//:go_default_library",
        "//cmd/protoc-gen-operatorlocal:go_default_library",
        "//cmd/protoc-gen-operatorctl:go_default_library",
        "//cmd/protoc-gen-operatord:go_default_library",
        "//protolog:go_default_library",
        "//generator:go_default_library",
        "//hipchat:go_default_library",
        "//testing:go_default_library",
    ]
)

sh_binary(
    name = "golint",
    srcs = ["golint.sh"],
    data = [
        "//:operator.proto",
        "@com_github_golang_lint//golint:golint",
		],
    visibility = ["//visibility:public"],
)

genrule(
    name = "go_google_protobuf",
    srcs = ["@com_github_golang_protobuf//ptypes/duration:go_default_library_protos"],
    outs = ["google/protobuf/duration.proto"],
    cmd = "cp $(<) $(@D)",
)

proto_gen(
    name = "operatorctl_genproto",
    srcs = [
        "testing.proto"
    ],
    deps = [
        ":go_google_protobuf",
        "//:operator.proto",
        "@com_github_golang_protobuf//ptypes/duration:go_default_library_protos",
    ],
    outs = [
        "main-gen.go"
    ],
    includes = [
        ".",
        "testing",
    ],
    plugin = "//cmd/protoc-gen-operatorctl",
    plugin_options = ["import_path=github.com/sr/operator/testing"],
    protoc = "@com_github_google_protobuf//:protoc",
)
