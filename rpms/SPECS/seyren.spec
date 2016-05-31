%define maven_version 3.3.9

Name: seyren
Version: 1.3.0
Release: 3%{?dist}
Summary: An alerting dashboard for Graphite
Group: Applications/Internet
License: Apache License v2.0
URL: https://github.com/scobal/seyren
Source0: https://github.com/scobal/seyren/archive/%{version}.tar.gz
Patch0: https://gist.githubusercontent.com/alindeman/2b6e2e29e51119dcb8f3a4f8fc3d5b93/raw/c9a31512c8b823994a812fcc2f1b008f1b21488a/seyren-1.3.0-use-http-proxy.patch
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
