Name: phantomjs
Version: 2.0
Release: 1%{?dist}
Summary: Scriptable Headless WebKit
Group: Applications/Internet
License: BSD
URL: https://github.com/ariya/phantomjs
Source0: https://github.com/ariya/phantomjs/archive/%{version}.tar.gz
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: make
BuildRequires: flex
BuildRequires: bison
BuildRequires: gperf
BuildRequires: ruby
BuildRequires: openssl-devel
BuildRequires: freetype-devel
BuildRequires: fontconfig-devel
BuildRequires: libicu-devel
BuildRequires: sqlite-devel
BuildRequires: libpng-devel
BuildRequires: libjpeg-devel
Requires: openssl
Requires: freetype
Requires: fontconfig
Requires: libicu
Requires: sqlite
Requires: libpng
Requires: libjpeg
BuildRoot: %{_tmppath}/%name-root

%description
Scriptable Headless WebKit

%prep
%setup -q -n phantomjs-%{version}

%build
./build.sh --confirm

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -m 755 bin/phantomjs $RPM_BUILD_ROOT/usr/bin/phantomjs

%files
%defattr(-,root,root,-)
/usr/bin/phantomjs

%clean
rm -rf $RPM_BUILD_ROOT
