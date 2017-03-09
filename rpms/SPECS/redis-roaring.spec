%define destination_directory /opt/pardot/redis-roaring
Name: redis-roaring
Version: master
Release: 1%{?dist}
Summary: Redis Roaring Bitmaps
Group: Applications/Internet
License: Salesforce
URL: https://git.dev.pardot.com/natalie-marion/redis-roaring
# Source0: https://git.dev.pardot.com/natalie-marion/redis-roaring/archive/%{version}.tar.gz
## Can't pull from internal git because the VM doesn't know how to get to it :\
## Download tar.gz from https://git.dev.pardot.com/natalie-marion/redis-roaring/releases
## cp ~/Downloads/redis-roaring-%{version}.tar.gz /path/to/rpms/SOURCES
Source0: redis-roaring-%{version}.tar.gz

BuildRequires: gcc
BuildRequires: cmake

%description
Roaring bitmaps implemented as a Redis Module

%prep
%setup -q -n redis-roaring-%{version}

%build
cmake .
make all

%install
rm -rf %{buildroot}%{destination_directory}
mkdir -p %{buildroot}%{destination_directory}
install -p -m 0755 ./lib/redis-roaring.so %{buildroot}%{destination_directory}/redis-roaring.so

%files
%defattr(-,root,root,-)
%{destination_directory}/redis-roaring.so
