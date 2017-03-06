# Working with Go code in this source tree

If you don't have Go installed already, please follow the official documentation:

https://golang.org/doc/install

Version 1.8 is required.

```
$ go version
go version go1.8 darwin/amd64
```

## Setup

The repository needs to be checked out at the correct location under [`$GOPATH`](https://golang.org/doc/code.html?h=workspace#GOPATH). The easiest way to do this is to use `go get`, which will download the repository into the correct directory in your home directory:

```
$ go get git.dev.pardot.com/Pardot/bread
```

If this is an existing checkout, move it to the correct location using these two commands:

```
$ mkdir -p "$(go env GOPATH)/src/git.dev.pardot.com/Pardot"
$ mv "${HOME}/path/to/checkout" "$(go env GOPATH)/src/git.dev.pardot.com/Pardot/bread"
```

We recommended adding `"$(go env GOPATH)/bin"` to your `$PATH` so that all built commands are available to the shell. The rest of this document assumes this is the case.

```
export PATH="$(go env GOPATH)/bin:$PATH"
```

See also: https://golang.org/doc/code.html#Workspaces

## Documentation

We recommend using `godoc` to explore the Go code in this source tree. To view it in your browser:

```
$ godoc -http=:6060 &
$ open http://localhost:6060/pkg/git.dev.pardot.com/Pardot/bread/
```

Alternatively, use the `godoc` command line program to view the documentation in your terminal:

```
godoc ./
```

See also: https://blog.golang.org/godoc-documenting-go-code

## Building and running tests

To build all Go code in this source tree, use the standard Go command:

```
$ go install -v ./...
```

Same for running the tests:

```
$ go test ./...
```

See also: https://golang.org/cmd/go/#hdr-Compile_and_install_packages_and_dependencies

## Linting

Before pushing changes to the central repository, be sure to verify all Go code is properly formatted:

```
$ tools/lint
```

This also checks for common mistakes and is required to exit non-zero on the build servers.

## Vendoring

This project uses a single [Vendor Directory](https://golang.org/cmd/go/#hdr-Vendor_Directories). All dependencies must be vendored under the `/vendor` directory.

Dependencies are managed using the [`gvt`](https://github.com/FiloSottile/gvt) utility, which is itself vendored. To install it:

```
$ go install ./vendor/github.com/FiloSottile/gvt
```

To add a new dependency:

```
$ gvt fetch github.com/user/repo/package
```

Please read `gvt -help` for more details.
