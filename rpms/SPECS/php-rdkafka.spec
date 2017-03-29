%define modname rdkafka
%define phpver 7.0.8
%define srcver 3.0.1
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:    Kafka client based on librdkafka
Name:       php-%{modname}
Version:    %{phpver}
Release:    1.pardot%{?dist}
Group:      Development/Languages
License:    Apache License
URL:        https://github.com/arnaud-lb/php-rdkafka
Source0:    https://github.com/arnaud-lb/php-rdkafka/archive/%{srcver}.zip
BuildRequires:  php-cli%{?_isa} = %{version}
BuildRequires:  php-devel%{?_isa} = %{version}
BuildRequires:  librdkafka-devel
BuildRequires:  re2c
BuildRoot:  %{_tmppath}/%name-root

%description
This extension is a librdkafka binding providing a working client for Kafka 0.8, 0.9, 0.10

%prep
%setup -q -n php-rdkafka-%{srcver}

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
%doc CONTRIBUTING.md LICENSE README.md CREDITS
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
