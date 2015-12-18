Name: kibana
Version: 4.3.1
Release: 1%{?dist}
Summary: Kibana is a browser based analytics and search dashboard for Elasticsearch
Group: Applications/Internet
License: APACHE 2.0
URL: https://github.com/elastic/kibana
Source0: https://download.elastic.co/kibana/kibana/kibana-4.3.1-linux-x64.tar.gz
Requires: java
Requires: openssl
BuildRoot: %{_tmppath}/%name-root

%description
Kibana is an open source (Apache Licensed), browser based analytics and search dashboard for Elasticsearch. Kibana is a snap to setup and start using. Kibana strives to be easy to get started with, while also being flexible and powerful, just like Elasticsearch.

%prep
%setup -q

%build

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -D %{_build}/bin


%files
%defattr(-,root,root,-)
/opt/kibana

%clean
rm -rf $RPM_BUILD_ROOT
