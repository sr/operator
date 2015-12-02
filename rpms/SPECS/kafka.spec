Name: kafka
Version: 0.9.0.0
Release: 1
Summary: Kafka is a distributed, partitioned, replicated commit log service
Group: Applications/Internet
License: Apache
URL: http://kafka.apache.org/
Source0: http://www.us.apache.org/dist/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
Kafka is a distributed, partitioned, replicated commit log service

%prep
%setup -q -n kafka_2.11-%{version}

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/usr/local
cp -rp ../* $RPM_BUILD_ROOT/usr/local/

%files
/usr/local/kafka_2.11-0.9.0.0/*

%clean
rm -rf $RPM_BUILD_ROOT
