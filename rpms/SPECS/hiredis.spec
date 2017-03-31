Summary: hiredis
Name: hiredis
Version: 0.11.0
Release: 1%{?dist}
License: BSD
Group: Applications/Multimedia
URL: http://github.com/redis/hiredis
Source0: https://github.com/redis/hiredis/archive/v%{version}.tar.gz 
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: gcc, make
Provides: hiredis

%description
Minimalistic C client for Redis 

%prep
%setup

%build
make %{?_smp_mflags} OPTIMIZATION="%{optflags}"

%install
make install PREFIX=%{buildroot}%{_prefix} INSTALL_LIBRARY_PATH=%{buildroot}%{_libdir}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
%{_libdir}/
%{_includedir}/
