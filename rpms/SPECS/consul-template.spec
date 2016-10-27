%define bin_dir /usr/local/bin/

Summary: Generic template rendering and notifications with Consul
Name: consul-template
Version: 0.16.0
Release: 1.pardot%{?dist}
Group: System Environment/Daemons
License: MPLv2.0
URL: http://www.consul.io
Source0: https://releases.hashicorp.com/%{name}/%{version}/%{name}_%{version}_linux_amd64.zip
Source1: %{name}.init
Source2: base.hcl

%description
Generic template rendering and notifications with Consul

%prep
%setup -q -c -n %{name}_%{version}

%install
mkdir -p %{buildroot}/%{bin_dir}
cp consul-template %{buildroot}/%{bin_dir}
mkdir -p %{buildroot}/%{_sysconfdir}/%{name}
mkdir -p %{buildroot}/%{_sysconfdir}/%{name}/templates
mkdir -p %{buildroot}/%{_sysconfdir}/%{name}/conf.d
cp %{SOURCE2} %{buildroot}/%{_sysconfdir}/%{name}/conf.d/
mkdir -p %{buildroot}/%{_initrddir}
cp %{SOURCE1} %{buildroot}/%{_initrddir}/%{name}

%files
%defattr(-,root,root,-)
%dir %attr(755, root, root) %{_sysconfdir}/%{name}
%dir %attr(755, root, root) %{_sysconfdir}/%{name}/templates
%dir %attr(755, root, root) %{_sysconfdir}/%{name}/conf.d
%attr(644, root, root) %{_sysconfdir}/%{name}/conf.d/base.hcl
%attr(755, root, root) %{_initrddir}/%{name}
%attr(755, root, root) %{bin_dir}/%{name}

%clean
rm -rf %{buildroot}
