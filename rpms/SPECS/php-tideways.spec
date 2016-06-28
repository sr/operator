%define modname tideways
%define phpver 7.0.8
%define srcver 4.0.5
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:  PHP profiler extension - Tideways a modern XHPROF alterative
Name:   php-%{modname}
Version:  %{phpver}
Release:  1.pardot%{?dist}
Group:    Development/Languages
License:  Apache License
URL:    https://github.com/tideways/php-profiler-extension
Source0:    https://github.com/tideways/php-profiler-extension/archive/v%{srcver}.zip
BuildRequires: php-cli%{?_isa} = %{version}
BuildRequires: php-devel%{?_isa} = %{version}

%description
This extension provides Tideways - a modern XHPROF alterative

%prep
%setup -q -n php-profiler-extension-%{srcver}

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
tideways.auto_prepend_library=0
EOF

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%doc NOTICE LICENSE README.md CHANGELOG.md
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
