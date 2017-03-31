Name: phantomjs
Version: 2.1.1
Release: 1%{?dist}
Summary: Scriptable Headless WebKit
Group: Applications/Internet
License: BSD
URL: https://github.com/ariya/phantomjs
Source0: https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-%{version}-linux-x86_64.tar.bz2
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
%setup -q -n phantomjs-%{version}-linux-x86_64

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/usr/bin
install -m 755 bin/phantomjs $RPM_BUILD_ROOT/usr/bin/phantomjs

%files
%defattr(-,root,root,-)
/usr/bin/phantomjs

%clean
rm -rf $RPM_BUILD_ROOT
