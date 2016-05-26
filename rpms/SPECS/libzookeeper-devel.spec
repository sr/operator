%define _noarch_libdir %{_libdir}
%define rel_ver 3.4.6

Summary: Headers and static libraries for libzookeeper
Name: libzookeeper-devel
Version: %{rel_ver}
Release: 1
License: Apache License v2.0
Group: Development/Libraries
URL: http://hadoop.apache.org/zookeeper/
Source0: http://mirror.cogentco.com/pub/apache/zookeeper/zookeeper-%{rel_ver}/zookeeper-%{rel_ver}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{rel_ver}-%{release}-root
BuildRequires: python-devel,gcc,make,libtool,autoconf,cppunit-devel
AutoReqProv: no

%description
This package contains the libraries and header files needed for
developing with libzookeeper.

%define _zookeeper_noarch_libdir %{_noarch_libdir}/zookeeper
%define _maindir %{buildroot}%{_zookeeper_noarch_libdir}

%prep
%setup -q -n zookeeper-%{rel_ver}

%build
pushd src/c
rm -rf aclocal.m4 autom4te.cache/ config.guess config.status config.log \
    config.sub configure depcomp install-sh ltmain.sh libtool \
    Makefile Makefile.in missing stamp-h1 compile
autoheader
libtoolize --force
aclocal
automake -a
autoconf
autoreconf
%configure
%{__make} %{?_smp_mflags}
popd

%install
rm -rf %{buildroot}
%{makeinstall} -C src/c
rm -rf %{buildroot}/usr/bin

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%doc src/c/README src/c/LICENSE
%{_libdir}/libzookeeper_mt.so.*
%{_libdir}/libzookeeper_st.so.*
%{_includedir}
%{_libdir}/*.a
%{_libdir}/*.la
%{_libdir}/*.so
