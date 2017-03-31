%define _noarch_libdir %{_libdir}
%define rel_ver 3.4.6

Summary: Headers and static libraries for libzookeeper
Name: libzookeeper-devel
Version: 3.4.6
Release: 1.pardot%{?dist}
License: Apache License v2.0
Group: Development/Libraries
URL: http://hadoop.apache.org/zookeeper/
Source0: http://mirror.cogentco.com/pub/apache/zookeeper/zookeeper-%{version}/zookeeper-%{version}.tar.gz
BuildRequires: python-devel,gcc,make,libtool,autoconf,cppunit-devel

%description
This package contains the libraries and header files needed for
developing with libzookeeper.

%prep
%setup -q -n zookeeper-%{version}

%build
pushd src/c
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
