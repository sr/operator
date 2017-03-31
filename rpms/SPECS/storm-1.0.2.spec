Name: storm
Version: 1.0.2
Release: 1%{?dist}
BuildArch: noarch
Summary: Apache Storm is a free and open source distributed realtime computation system.
Group: Applications/Internet
License: Apache
URL: http://storm.apache.org/
Source0: http://mirror.nus.edu.sg/apache/storm/apache-storm-%{version}/apache-storm-%{version}.tar.gz
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
Apache Storm is a free and open source distributed realtime computation system.

%prep
%setup -q -n apache-storm-%{version}
rm -rf examples

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/opt/storm/apache-storm-%{version}
cp -rp * $RPM_BUILD_ROOT/opt/storm/apache-storm-%{version}

%files
%defattr(-,storm,storm,-)
/opt/storm/apache-storm-%{version}

%pre
# Check if custom group 'storm' exists. If not, create it.
getent group storm >/dev/null || groupadd -r storm

# Check if custom user 'storm' exists. If not, create it.
getent passwd storm >/dev/null || \
    useradd -r -M -g storm -s /bin/false \
    -c "Storm service account" storm

%clean
rm -rf $RPM_BUILD_ROOT
