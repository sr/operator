Name: kibana
Version: 4.3.1
Release: 1%{?dist}
Summary: Kibana is a browser based analytics and search dashboard for Elasticsearch
Group: Applications/Internet
License: APACHE 2.0
URL: https://github.com/elastic/kibana
Source0: https://download.elastic.co/kibana/kibana/kibana-%{version}-linux-x64.tar.gz
Requires: java
Requires: openssl
BuildRoot: %{_tmppath}/%name-root

%define debug_package %{nil}

%description
Kibana is an open source (Apache Licensed), browser based analytics and search dashboard for Elasticsearch. Kibana is a snap to setup and start using. Kibana strives to be easy to get started with, while also being flexible and powerful, just like Elasticsearch.

%prep
%setup -q -n kibana-%{version}-linux-x64

%build

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/opt/kibana
install -m 0755 -d $RPM_BUILD_ROOT/var/log/kibana
install -m 0755 -d $RPM_BUILD_ROOT/var/run/kibana
cp -rp . $RPM_BUILD_ROOT/opt/kibana

%files
%defattr(-,kibana,kibana,-)
/opt/kibana
%dir /var/log/kibana
%dir /var/run/kibana

%clean
rm -rf $RPM_BUILD_ROOT
