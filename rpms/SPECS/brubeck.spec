%global brubeck_git_revision 5d139a44206813640151cf0af17d32ee9ac41a60

Name: brubeck
Version: 1.0.0
Release: 9%{?dist}
Summary: A Statsd-compatible metrics aggregator
Group: Applications/Internet
License: MIT
URL: https://github.com/github/brubeck
Source0: https://github.com/github/brubeck/archive/%{brubeck_git_revision}.tar.gz
Patch0: https://patch-diff.githubusercontent.com/raw/github/brubeck/pull/31.patch
BuildRequires: gcc
BuildRequires: git
BuildRequires: jansson-devel >= 2.5
BuildRequires: libmicrohttpd-devel
BuildRequires: openssl-devel
BuildRoot: %{_tmppath}/%name-root

%description
A Statsd-compatible metrics aggregator developed by GitHub.

%prep
%setup -q -n brubeck-%{brubeck_git_revision}
%patch0 -p1

git clone https://github.com/concurrencykit/ck vendor/ck
pushd vendor/ck
git checkout 1a84d49c3ca794356f015a3391e6d10be98f6a6a
popd

%build
make brubeck

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -m 755 brubeck $RPM_BUILD_ROOT/usr/bin/brubeck

%files
%defattr(-,root,root,-)
/usr/bin/brubeck

%clean
rm -rf $RPM_BUILD_ROOT
