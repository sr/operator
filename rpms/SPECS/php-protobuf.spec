%define modname protobuf
%define phpver 7.0.8
%define soname %{modname}.so
%define inifile 20-%{modname}.ini
%define repoversion php7

Summary:       PHP module for protobufs
Name:          php-%{modname}
Version:       %{phpver}
Release:       1.pardot%{?dist}
License:       BSD
Group:         Development/Languages
URL:           https://github.com/allegro/php-protobuf
Source0:       https://github.com/pd-aray/php-protobuf/archive/%{repoversion}.tar.gz
BuildRequires: php-cli%{?_isa} = %{version}
BuildRequires: php-devel%{?_isa} = %{version}

%description
https://github.com/allegro/php-protobuf

%prep
%setup -q -n php-protobuf-%{repoversion}

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
%doc CREDITS LICENSE.md README.md
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
