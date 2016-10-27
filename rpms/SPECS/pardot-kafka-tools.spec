%define maven_version 3.3.9
%define srcver 2.0

Name: pardot-kafka-tools
Version: %{srcver}
Release: 1%{?dist}
Summary: Random Pardot Kafka Tools
Group: Applications/Internet
License: Apache License v2.0
URL: https://git.dev.pardot.com/pardot/kafka-tools
#Source0: https://git.dev.pardot.com/Pardot/kafka-tools/archive/%{srcver}.tar.gz
## Sorry, cant pull from github because the VM doesnt have access to it :(
## Please follow these steps:
## 1. git clone git@git.dev.pardot.com:Pardot/kafka-tools.git
## 2. cd kafka-tools
## 3. mvn clean package -U
## 4. cp target/*.jar to rpms/SOURCES
##
Source0: kafka-tools-%{srcver}-SNAPSHOT-jar-with-dependencies.jar
BuildArch: noarch
BuildRoot: %{_tmppath}/%name-root

%description
Random collection of Kafka tools pardot has built.

%prep

#%setup -q -n kafka-tools-%{srcver}

%build

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/opt/kafka/current/lib
install -m 0644 %{SOURCE0} $RPM_BUILD_ROOT/opt/kafka/current/lib/pardot-kafka-tools-%{srcver}.jar

%files
%defattr(-,kafka,kafka,-)
/opt/kafka/current/lib/pardot-kafka-tools-%{srcver}.jar

%pre
# Check if custom group 'kafka' exists. If not, create it.
getent group kafka >/dev/null || groupadd -r kafka

# Check if custom user 'kafka' exists. If not, create it.
getent passwd kafka >/dev/null || \
    useradd -r -M -g kafka -s /bin/false \
    -c "Kafka service account" kafka

%clean
rm -rf $RPM_BUILD_ROOT