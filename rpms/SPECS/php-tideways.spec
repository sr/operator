%define modname tideways
%define phpver 7.0
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:  PHP profiler extension - Tideways a modern XHPROF alterative
Name:   php-%{modname}
Version:  4.0.4
Release:  1%{?dist}
Group:    Development/Languages
License:  Apache License
URL:    https://github.com/tideways/php-profiler-extension
Source0:    https://github.com/tideways/php-profiler-extension/archive/v4.0.4.zip
BuildRequires: php-cli >= %{phpver}
BuildRequires: php-devel >= %{phpver}

%description
This extension provides Tideways - a modern XHPROF alterative

%prep
%setup -q -n php-profiler-extension-%{version}

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
%doc NOTICE LICENSE README.md CHANGELOG.md
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
