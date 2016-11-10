%define srcver 1.0.0

Name: storm-supervisor-validator
Version: %{srcver}
Release: 1%{?dist}
Summary: Pardots Storm Supervisor Validator Tool
Group: Applications/Internet
License: Apache License v2.0
URL: https://git.dev.pardot.com/Pardot/StormSupervisorValidationTool
## Sorry, cant pull from github because the VM doesnt have access to it :(
## Please follow these steps:
## 1. git clone git@git.dev.pardot.com:Pardot/StormSupervisorValidationTool.git
## 2. cd StormSupervisorValidationTool
## 3. mvn clean package -U
## 4. cp target/*.jar to rpms/SOURCES
##
Source0: StormValidation-%{srcver}-SNAPSHOT-jar-with-dependencies.jar
BuildArch: noarch
BuildRoot: %{_tmppath}/%name-root

%description
Validation tool to validate Pardots Storm Supervisor hosts.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/opt/storm
install -m 0644 %{SOURCE0} $RPM_BUILD_ROOT/opt/storm/StormValidation-%{srcver}.jar

%files
%defattr(-,storm,storm,-)
/opt/storm/StormValidation-%{srcver}.jar

%pre
# Check if custom group 'storm' exists. If not, create it.
getent group storm >/dev/null || groupadd -r storm

# Check if custom user 'storm' exists. If not, create it.
getent passwd storm >/dev/null || \
    useradd -r -M -g storm -s /bin/false \
    -c "Storm service account" storm

%clean
rm -rf $RPM_BUILD_ROOT