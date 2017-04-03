# rpms

A buildroot for building custom RPMs.

## Prerequisites

1. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. [Vagrant](https://www.vagrantup.com/downloads.html)

## Usage

### Building a new package

1. Create a `<package>.spec` file in the `SPECS/` directory.
1. Run `script/build <package>`.

```
script/build <package>

# example
script/build brubeck

# build for CentOS 5
MACHINE=el5 script/build brubeck
```

Submit a PR for your spec file, then after +1 and merging, upload your RPM via:

### Uploading a new package
1. Run `script/upload <package>`.
1. *You will need an Artifactory and HipChat Token to upload, details below

```
script/upload </path/to/package*.rpm>

# example
script/upload RPMS/x86_64/php-tideways-7.0.8-1.pardot.el6.x86_64.rpm
```

#### What happens after upload?
Once your RPM is successfully uploaded to the Artifactory server, it will be available to environments *outside* SFDC (test-kitchen, AWS servers, etc) within about 1-2 minutes. Next it will be mirrored and available locally within the SFDC datacenters (DFW/PHX) within 10 minutes.

#### Artifactory and HipChat Tokens
* [Create an Artifactory API Token](https://artifactory.dev.pardot.com/artifactory/webapp/#/profile) and add it to your shell environment as `ARTIFACTORY_API_KEY`.
* [Create a HipChat API Token](https://hipchat.dev.pardot.com/account/api) and add it to your shell environment as `HIPCHAT_TOKEN`.

```
# example, adding the values to your ~/.bash_profile
export HIPCHAT_TOKEN="MY-HIPCHAT-TOKEN-STRING"
export ARTIFACTORY_API_KEY="MY-ARTIFACTORY-TOKEN-STRING"
```

## Caveats

### Tarballs from GitHub Enterprise

`rpmbuild` is not able to download tarballs from GitHub Enterprise. If one of the sources for a package is hosted on `git.dev.pardot.com`, you'll need to download the file yourself and put it in `SOURCES/` on the Vagrant VM.

Then, build the package with the `-n` flag, which signals to the automation that it should not try to download sources:

```
script/build -n <package>
```

## Resources

* [Working with Spec Files](https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch-specfiles.html) from the Fedora documentation
