%define modname zookeeper
%define phpver 7.0
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:	PHP extension for interfacing with Apache ZooKeeper
Name:		php-%{modname}
Version:	0.3.0
Release:	1%{?dist}
Group:		Development/Languages
License:	PHP License
URL:		https://github.com/mikemfrank/php-zookeeper
Source0:    https://github.com/mikemfrank/php-zookeeper/archive/v0.3.0.tar.gz
BuildRequires: libzookeeper-devel
BuildRequires: php-cli >= %{phpver}
BuildRequires: php-devel >= %{phpver}

%description
This extension provides API for communicating with ZooKeeper service.

%prep
%setup -q

%build
phpize
%configure
make
mv modules/*.so .

%install
rm -rf %{buildroot}

install -d %{buildroot}%{_libdir}/php/modules
install -d %{buildroot}%{_sysconfdir}/php.d

install -m755 %{soname} %{buildroot}%{_libdir}/php/modules/

cat > %{buildroot}%{_sysconfdir}/php.d/%{inifile} << EOF
extension = %{soname}
EOF

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%doc CREDITS ChangeLog LICENSE README.markdown zookeeper-api.php package*.xml
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
