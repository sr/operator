# rpms

A buildroot for building custom RPMs.

## Prerequisites

1. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. [Vagrant](https://www.vagrantup.com/downloads.html)

## Usage

### tl;dr

```
script/build <package>

# example
script/build brubeck

# build for CentOS 5
MACHINE=el5 script/build brubeck
```

### Building a new package

1. Create a `<package>.spec` file in the `SPECS/` directory.
1. Run `script/build <package>`.
1. Copy `RPMS/x86_64/package*.rpm` to the RPM server.
1. Have a cool beverage of your choice.

## Caveats

### Tarballs from GitHub Enterprise

`rpmbuild` is not able to download tarballs from GitHub Enterprise. If one of the sources for a package is hosted on `git.dev.pardot.com`, you'll need to download the file yourself and put it in `SOURCES/` on the Vagrant VM.

Then, build the package with the `-n` flag, which signals to the automation that it should not try to download sources:

```
script/build -n <package>
```

## Resources

* [Working with Spec Files](https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch-specfiles.html) from the Fedora documentation
