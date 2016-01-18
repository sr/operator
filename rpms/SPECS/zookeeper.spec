Name: zookeeper
Version: 3.4.6
Release: 1%{?dist}
Summary: ZooKeeper is a high-performance coordination service for distributed applications.
Group: Applications/Internet
License: Apache
URL: https://zookeeper.apache.org/
Source0: http://mirrors.ibiblio.org/apache/zookeeper/zookeeper-%{version}/zookeeper-%{version}.tar.gz
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
ZooKeeper is a high-performance coordination service for distributed applications. It exposes common services - such as naming, configuration management, synchronization, and group services - in a simple interface so you don't have to write them from scratch. You can use it off-the-shelf to implement consensus, group management, leader election, and presence protocols. And you can build on it for your own, specific needs.

%prep
%setup -q -n zookeeper-%{version}

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/opt/zookeeper/zookeeper-%{version}
cp -rp * $RPM_BUILD_ROOT/opt/zookeeper/zookeeper-%{version}

%files
%defattr(-,zookeeper,zookeeper,-)
/opt/zookeeper/zookeeper-%{version}

%pre
# Check if custom group 'zookeeper' exists. If not, create it.
getent group zookeeper >/dev/null || groupadd -r zookeeper

# Check if custom user 'zookeeper' exists. If not, create it.
getent passwd zookeeper >/dev/null || \
    useradd -r -M -g zookeeper -s /bin/false \
    -c "zookeeper service account" zookeeper

%clean
rm -rf $RPM_BUILD_ROOT
