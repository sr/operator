Name: proxychains-ng
Version: 4.11
Release: 1%{?dist}
Summary: HTTP-proxy hook preloader
Group: Applications/Internet
License: GPLv2
URL: https://sourceforge.net/projects/proxychains-ng/
Source0: https://downloads.sourceforge.net/project/proxychains-ng/proxychains-ng-%{version}.tar.bz2
BuildRoot: %{_tmppath}/%name-root

%description
proxychains is a hook preloader that allows to redirect TCP traffic of existing
dynamically linked programs through one or more SOCKS or HTTP proxies.

%prep
%setup -q -n proxychains-ng-%{version}

%build
%configure
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
%make_install
make install-config DESTDIR=$RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%config(noreplace) /etc/proxychains.conf
%{_bindir}/proxychains4
%{_libdir}/libproxychains4.so

%clean
rm -rf $RPM_BUILD_ROOT
