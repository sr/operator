%define modname phpiredis 
%define phpver 7.0.8
%define soname %{modname}.so
%define inifile %{modname}.ini
%define repoversion 1.0.0 

Summary:       PHP module for phpiredis
Name:          %{modname}
Version:       %{phpver}
Release:       1.pardot%{?dist}
License:       BSD
Group:         Development/Languages
URL:           https://github.com/nk/phpiredis
Source0:       https://github.com/vpothuri/phpiredis/archive/%{repoversion}.tar.gz
BuildRequires: php-cli%{?_isa} = %{version}
BuildRequires: php-devel%{?_isa} = %{version}

%description
https://github.com/nk/phpiredis

%prep
%setup -q -n phpiredis-%{repoversion}

%build
phpize
./configure --enable-phpiredis
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
%doc README.md
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
