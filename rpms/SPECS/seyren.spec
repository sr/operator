%define maven_version 3.3.9

Name: seyren
Version: 1.3.0
Release: 5%{?dist}
Summary: An alerting dashboard for Graphite
Group: Applications/Internet
License: Apache License v2.0
URL: https://github.com/scobal/seyren
Source0: https://github.com/scobal/seyren/archive/%{version}.tar.gz
Patch0: https://patch-diff.githubusercontent.com/raw/scobal/seyren/pull/290.patch
Patch1: https://gist.githubusercontent.com/alindeman/e86ef1c5c60d67d2c153e5b565fa2d62/raw/c08452ca570f32f4a2d37b3182b8092dd821bec5/340.patch
BuildArch: noarch
BuildRequires: java-1.8.0-openjdk-devel
BuildRequires: curl
BuildRoot: %{_tmppath}/%name-root

%description
An alerting dashboard for Graphite

%prep
# Install Maven first
curl -o maven.tar.gz "http://apache.osuosl.org/maven/maven-3/%{maven_version}/binaries/apache-maven-%{maven_version}-bin.tar.gz"
tar -xvzf maven.tar.gz
rm maven.tar.gz

%setup -q -n seyren-%{version}
%patch0 -p1
%patch1 -p1

%build
../apache-maven-%{maven_version}/bin/mvn clean package -DskipTests

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/opt/seyren
install -m 0644 seyren-web/target/seyren-web-%{version}.war $RPM_BUILD_ROOT/opt/seyren/seyren.war

%files
%defattr(-,root,root,-)
/opt/seyren/seyren.war

%clean
rm -rf $RPM_BUILD_ROOT
