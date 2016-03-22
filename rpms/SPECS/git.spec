Name: git
Version: 2.7.4
Release: 1%{?dist}
Summary: Fast Version Control System
License: GPLv2
Group: Development/Tools
URL: http://git-scm.com/
Source0: https://www.kernel.org/pub/software/scm/git/git-%{version}.tar.xz
BuildRequires: expat-devel
BuildRequires: libcurl-devel
BuildRequires: openssl-devel
BuildRequires: perl
BuildRequires: perl-ExtUtils-MakeMaker
BuildRequires: perl-libintl
BuildRequires: zlib-devel
Requires: perl
Requires: perl-libintl
Requires: zlib
Obsoletes: perl-Git

%define _unpackaged_files_terminate_build 0

%description
Git is a fast, scalable, distributed revision control system with an
unusually rich command set that provides both high-level operations
and full access to internals.

%prep
%setup -q

%build
%configure
make %{?_smp_mflags} BLK_SHA1=1 all

%install
rm -rf $RPM_BUILD_ROOT
make %{?_smp_mflags} DESTDIR=$RPM_BUILD_ROOT install

%files
%defattr(-,root,root,-)
%{_bindir}/git
%{_bindir}/git-cvsserver
%{_bindir}/git-receive-pack
%{_bindir}/git-shell
%{_bindir}/git-upload-archive
%{_bindir}/git-upload-pack
%{_libexecdir}/git-core
%{_datadir}/git-core
%{_datadir}/locale
%{_datadir}/perl5
%{_mandir}/man3

%clean
rm -rf $RPM_BUILD_ROOT
