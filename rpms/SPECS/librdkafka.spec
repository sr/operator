%define srcver 0.9.4
%define soname 1

Name:       librdkafka
Version:    %{srcver}
Release:    1%{?dist}

Summary:    The Apache Kafka C library
Group:      Development/Libraries
License:    BSD-2-Clause
URL:        https://github.com/edenhill/librdkafka
Source0:    https://github.com/edenhill/librdkafka/archive/v%{srcver}.tar.gz

BuildRequires: zlib-devel libstdc++-devel gcc >= 4.1 gcc-c++ openssl-devel cyrus-sasl-devel lz4-devel python
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
Librdkafka is a C/C++ library implementation of the Apache Kafka protocol,
containing both Producer and Consumer support.
It was designed with message delivery reliability and high performance in mind,
current figures exceed 800000 messages/second for the producer and 3 million
messages/second for the consumer.

%package -n %{name}%{soname}
Summary: The Apache Kafka C library
Group:   Development/Libraries
Requires: zlib libstdc++ cyrus-sasl

%description -n %{name}%{soname}
librdkafka is the C/C++ client library implementation of the Apache Kafka protocol, containing both Producer and Consumer support.


%package -n %{name}-devel
Summary: The Apache Kafka C library (Development Environment)
Group:   Development/Libraries
Requires: %{name}%{soname} = %{version}

%description -n %{name}-devel
librdkafka is the C/C++ client library implementation of the Apache Kafka protocol, containing both Producer and Consumer support.

This package contains headers and libraries required to build applications
using librdkafka.

%prep
%setup -q

%configure

%build
make

%install
rm -rf %{buildroot}
DESTDIR=%{buildroot} make install

%clean
rm -rf %{buildroot}

%post   -n %{name}%{soname} -p /sbin/ldconfig
%postun -n %{name}%{soname} -p /sbin/ldconfig

%files -n %{name}%{soname}
%defattr(444,root,root)
%{_libdir}/librdkafka.so.%{soname}
%{_libdir}/librdkafka++.so.%{soname}
%defattr(-,root,root)
%doc README.md CONFIGURATION.md INTRODUCTION.md
%doc LICENSE LICENSE.pycrc LICENSE.queue LICENSE.snappy LICENSE.tinycthread LICENSE.wingetopt

%defattr(-,root,root)
#%{_bindir}/rdkafka_example
#%{_bindir}/rdkafka_performance

%files -n %{name}-devel
%defattr(-,root,root)
%{_includedir}/librdkafka
%defattr(444,root,root)
%{_libdir}/librdkafka.a
%{_libdir}/librdkafka.so
%{_libdir}/librdkafka++.a
%{_libdir}/librdkafka++.so
%{_libdir}/pkgconfig/rdkafka++.pc
%{_libdir}/pkgconfig/rdkafka.pc