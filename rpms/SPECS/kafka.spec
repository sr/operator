Name: kafka
Version: 0.9.0.0
Release: 1%{?dist}
BuildArch: noarch
Summary: Kafka is a distributed, partitioned, replicated commit log service
Group: Applications/Internet
License: Apache
URL: http://kafka.apache.org/
Source0: http://www.us.apache.org/dist/kafka/0.9.0.0/kafka_2.11-0.9.0.0.tgz
Source1: http://chef-repos.pardot.com/pardot/no-arch/kafka-statsd-reporter-1.0.1.jar
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
Kafka is a distributed, partitioned, replicated commit log service

%prep
%setup -q -n kafka_2.11-%{version}

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/opt/kafka/kafka_%{version}
cp -rp * $RPM_BUILD_ROOT/opt/kafka/kafka_%{version}
install -m0644 %{SOURCE1} $RPM_BUILD_ROOT/opt/kafka/kafka_%{version}/libs

%files
%defattr(-,kafka,kafka,-)
/opt/kafka/kafka_%{version}

%pre
# Check if custom group 'kafka' exists. If not, create it.
getent group kafka >/dev/null || groupadd -r kafka

# Check if custom user 'kafka' exists. If not, create it.
getent passwd kafka >/dev/null || \
    useradd -r -M -g kafka -s /bin/false \
    -c "Kafka service account" kafka

%clean
rm -rf $RPM_BUILD_ROOT
