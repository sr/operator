%define modname gnupg
%define phpver 7.0
%define soname %{modname}.so
%define inifile 20-%{modname}.ini

Summary:  Wrapper around the gpgme library
Name:   php-pecl-encryption-%{modname}
Version:  2.0.0
Release:  1%{?dist}
Group:    Development/Languages
License:  PHP License
URL:    https://github.com/Sean-Der/pecl-encryption-gnupg
Source0:    https://github.com/Sean-Der/pecl-encryption-gnupg/archive/gnupg-2.0.0.zip
BuildRequires: gpgme-devel
BuildRequires: gnupg
BuildRequires: php-cli >= %{phpver}
BuildRequires: php-devel >= %{phpver}

%description
This module allows you to interact with gnupg.

%prep
%setup -q -n pecl-encryption-gnupg-%{modname}-%{version}

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
%doc LICENSE README package.xml
%config(noreplace) %attr(0644,root,root) %{_sysconfdir}/php.d/%{inifile}
%attr(0755,root,root) %{_libdir}/php/modules/%{soname}
