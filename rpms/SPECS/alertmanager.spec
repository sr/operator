%define debug_package %{nil}

Name:		alertmanager
Version:	0.4.0
Release:	1%{?dist}
Summary:	The Alertmanager handles alerts sent by client applications such as the Prometheus server.
Group:		System Environment/Daemons
License:	See the LICENSE file at github.
URL:		https://github.com/prometheus/alertmanager
Source0:	https://github.com/prometheus/alertmanager/releases/download/v%{version}/alertmanager-%{version}.linux-amd64.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-root
AutoReqProv:	No

%description

The Alertmanager handles alerts sent by client applications such as the Prometheus server. 
It takes care of deduplicating, grouping, and routing them to the correct receiver integration such as email, PagerDuty, or OpsGenie. 
It also takes care of silencing and inhibition of alerts.

%prep
%setup -q -n %{name}-%{version}.linux-amd64

%build
echo

%install
mkdir -vp $RPM_BUILD_ROOT/opt/prometheus
install -m 755 alertmanager $RPM_BUILD_ROOT/opt/prometheus/alertmanager

%clean

%pre

%post

%files
%defattr(-,root,root,-)
/opt/prometheus/alertmanager
