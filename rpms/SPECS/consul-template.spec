%define bin_dir /usr/local/bin/

Summary: Generic template rendering and notifications with Consul
Name: consul-template
Version: 0.16.0
Release: 1.pardot%{?dist}
Group: System Environment/Daemons
License: MPLv2.0
URL: http://www.consul.io
Source0: https://releases.hashicorp.com/%{name}/%{version}/%{name}_%{version}_linux_amd64.zip

%description
Generic template rendering and notifications with Consul

%prep
%setup -q -c -n %{name}_%{version}

%install
mkdir -p %{buildroot}/%{bin_dir}
cp consul-template %{buildroot}/%{bin_dir}

%files
%defattr(-,root,root,-)
%attr(755, root, root) %{bin_dir}/%{name}

%clean
rm -rf %{buildroot}
