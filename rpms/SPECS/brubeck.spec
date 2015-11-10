Name: brubeck
Version: 1.0.0
Release: 3%{?dist}
Summary: A Statsd-compatible metrics aggregator
Group: Applications/Internet
License: MIT
URL: https://github.com/github/brubeck
Source0: https://git.dev.pardot.com/andy-lindeman/brubeck/archive/7fcf80d778edac1b1e00158d0147c82b4d4ec863.tar.gz
BuildRequires: gcc
BuildRequires: git
BuildRequires: jansson-devel >= 2.5
BuildRequires: libmicrohttpd-devel
BuildRequires: openssl-devel
Requires: jansson >= 2.5
Requires: libmicrohttpd
Requires: openssl

%description
A Statsd-compatible metrics aggregator developed by GitHub.

%prep
%setup -n brubeck-7fcf80d778edac1b1e00158d0147c82b4d4ec863
git clone -b 1a84d49c3ca794356f015a3391e6d10be98f6a6a https://github.com/concurrencykit/ck vendor/ck

%build
make brubeck

%install
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -m 755 brubeck $RPM_BUILD_ROOT/usr/bin/brubeck

%files
/usr/bin/brubeck
