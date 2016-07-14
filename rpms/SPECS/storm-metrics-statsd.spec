%define maven_version 3.3.9

Name: storm-metrics-statsd
Version: 1.0.0.SNAPSHOT
Release: 1%{?dist}
Summary: Storm plugin for reporting metrics to statsd
Group: Applications/Internet
License: Apache License v2.0
URL: https://github.com/jegeiger/storm-metrics-statsd
Source0: https://github.com/jegeiger/storm-metrics-statsd/archive/master.tar.gz
BuildArch: noarch
BuildRequires: java-1.7.0-openjdk-devel
BuildRequires: curl
BuildRoot: %{_tmppath}/%name-root

%description
Storm plugin for reporting metrics to statsd

%prep
# Install Maven first
curl -o maven.tar.gz "http://apache.osuosl.org/maven/maven-3/%{maven_version}/binaries/apache-maven-%{maven_version}-bin.tar.gz"
tar -xvzf maven.tar.gz
rm maven.tar.gz

%setup -q -n storm-metrics-statsd-master

%build
../apache-maven-%{maven_version}/bin/mvn clean package -DskipTests

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/opt/storm/current/lib
install -m 0755 target/storm-metrics-statsd-1.0.0-SNAPSHOT.jar $RPM_BUILD_ROOT/opt/storm/current/lib/storm-metrics-statsd.jar

%files
%defattr(-,root,root,-)
/opt/storm/current/lib/storm-metrics-statsd.jar

%clean
rm -rf $RPM_BUILD_ROOT
