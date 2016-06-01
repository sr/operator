%define modname protobuf
%define phpver 7.0
%define soname %{modname}.so
%define inifile 20-%{modname}.ini
%define repoversion php7

Summary:       PHP module for protobufs
Name:          php-%{modname}
Version:       %{repoversion}
Release:       1%{?dist}
License:       Open
Group:         PHP/Module
URL:           https://github.com/allegro/php-protobuf
Source0:       https://github.com/pd-array/php-protobuf/archive/%{repoversion}.tar.gz
Requires:      php >= %{phpver}
BuildRequires: php-cli >= %{phpver}
BuildRequires: php-devel >= %{phpver}

%description
https://github.com/allegro/php-protobuf

%prep
%setup -q

%build
phpize
%configure
make
mv modules/*.so .

%install
rm -rf %{buildroot}

install -d %{buildroot}%{_libdir}/php/extensions
install -d %{buildroot}%{_sysconfdir}/php.d

install -m755 %{soname} %{buildroot}%{_libdir}/php/extensions/

cat > %{buildroot}%{_sysconfdir}/php.d/%{inifile} << EOF
extension = %{soname}
EOF

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%doc CREDITS LICENSE.md README.md
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/extensions/%{soname}