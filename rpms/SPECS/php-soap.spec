%define modname soap
%define phpver 7.0.7
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:	A module for PHP applications that use the SOAP protocol
Name:		php-%{modname}
Version:	%{phpver}
Release:	1.pardot%{?dist}
Group:		Development/Languages
License:	PHP
URL:		http://www.php.net/
Source:		http://www.php.net/distributions/php-%{version}.tar.xz
Patch:		https://gist.githubusercontent.com/ksmiley/ab028f36e1545450f6746ba305c6c598/raw/817131937ab99455b16114f0f7a6d5f99e9fc52a/php-bug69137.patch
Requires:	php-common%{?_isa} = %{version}
BuildRequires:	libxml2-devel
BuildRequires:	php-devel = %{version}
BuildRoot:	%{_tmppath}/%name-root

%description
The php-soap package contains a dynamic shared object that will add
support to PHP for using the SOAP web services protocol.

%prep
%setup -q -n php-%{phpver}
%patch -p1

%build
cd ext/soap
phpize
%configure
make
mv modules/*.so .

%install
cd ext/soap
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
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
