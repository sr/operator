# -*- mode: python; -*- PYTHON-PREPROCESSING-REQUIRED
# Copyright 2014, Google Inc.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
# copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the
# distribution.
#     * Neither the name of Google Inc. nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Copied with some modifications from https://github.com/google/protobuf/blob/master/protobuf.bzl

def _GetPath(ctx, path):
  if ctx.label.workspace_root:
    return ctx.label.workspace_root + '/' + path
  else:
    return path

def _GenDir(ctx):
  if not ctx.attr.includes:
    return ctx.label.workspace_root
  if not ctx.attr.includes[0]:
    return _GetPath(ctx, ctx.label.package)
  if not ctx.label.package:
    return _GetPath(ctx, ctx.attr.includes[0])
  return _GetPath(ctx, ctx.label.package + '/' + ctx.attr.includes[0])

def _proto_gen_impl(ctx):
  """General implementation for generating protos"""
  srcs = ctx.files.srcs
  deps = []
  deps += ctx.files.srcs
  gen_dir = _GenDir(ctx)
  if gen_dir:
    import_flags = ["-I" + gen_dir, "-I" + ctx.var["GENDIR"] + "/" + gen_dir]
  else:
    import_flags = ["-I."]

  for file in ctx.files.deps:
    deps += [file]
    import_flags += ["-I" + file.dirname]

  args = []
  inputs = srcs + deps

  if ctx.executable.plugin:
    plugin = ctx.executable.plugin
    lang = ctx.attr.plugin_language
    if not lang and plugin.basename.startswith('protoc-gen-'):
      lang = plugin.basename[len('protoc-gen-'):]
    if not lang:
      fail("cannot infer the target language of plugin", "plugin_language")

    outdir = ctx.var["GENDIR"] + "/" + gen_dir
    if ctx.attr.plugin_options:
      outdir = ",".join(ctx.attr.plugin_options) + ":" + outdir
    args += ["--plugin=protoc-gen-%s=%s" % (lang, plugin.path)]
    args += ["--%s_out=%s" % (lang, outdir)]
    inputs += [plugin]

  if args:
    ctx.action(
        inputs=inputs,
        outputs=ctx.outputs.outs,
        arguments=args + import_flags + [s.path for s in srcs],
        executable=ctx.executable.protoc,
        mnemonic="ProtoCompile",
    )

  return struct(
      proto=struct(
          srcs=srcs,
          import_flags=import_flags,
          deps=deps,
      ),
  )

proto_gen = rule(
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "includes": attr.string_list(),
        "protoc": attr.label(
            cfg = "host",
            executable = True,
            single_file = True,
            mandatory = True,
        ),
        "plugin": attr.label(
            cfg = "host",
            allow_files = True,
            executable = True,
        ),
        "plugin_language": attr.string(),
        "plugin_options": attr.string_list(),
        "outs": attr.output_list(),
    },
    output_to_genfiles = True,
    implementation = _proto_gen_impl,
)
"""Generates codes from Protocol Buffers definitions.

This rule helps you to implement Skylark macros specific to the target
language. You should prefer more specific `cc_proto_library `,
`py_proto_library` and others unless you are adding such wrapper macros.

Args:
  srcs: Protocol Buffers definition files (.proto) to run the protocol compiler
    against.
  deps: a list of dependency labels; must be other proto libraries.
  includes: a list of include paths to .proto files.
  protoc: the label of the protocol compiler to generate the sources.
  plugin: the label of the protocol compiler plugin to be passed to the protocol
    compiler.
  plugin_language: the language of the generated sources
  plugin_options: a list of options to be passed to the plugin
  outs: a list of labels of the expected outputs from the protocol compiler.
"""
