%define debug_package %{nil}

Name:		prometheus
Version:	1.0.2
Release:	1%{?dist}
Summary:	Prometheus is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.
Group:		System Environment/Daemons
License:	See the LICENSE file at github.
URL:		https://github.com/prometheus/prometheus
Source0:	https://github.com/prometheus/prometheus/releases/download/v%{version}/prometheus-%{version}.linux-amd64.tar.gz
BuildRoot:	%{_tmppath}/%{name}-%{version}-root
AutoReqProv:	No

%description

Prometheus is a systems and service monitoring system.
It collects metrics from configured targets at given intervals, evaluates
rule expressions, displays the results, and can trigger alerts if
some condition is observed to be true.

%prep
%setup -q -n %{name}-%{version}.linux-amd64

%build
echo

%install
mkdir -vp $RPM_BUILD_ROOT/opt/prometheus/bin
mkdir -vp $RPM_BUILD_ROOT/opt/prometheus/consoles
mkdir -vp $RPM_BUILD_ROOT/opt/prometheus/console_libraries

install -m 755 prometheus $RPM_BUILD_ROOT/opt/prometheus/bin/prometheus
install -m 755 promtool $RPM_BUILD_ROOT/opt/prometheus/bin/promtool

install -m 755 console_libraries/menu.lib $RPM_BUILD_ROOT/opt/prometheus/console_libraries
install -m 755 console_libraries/prom.lib $RPM_BUILD_ROOT/opt/prometheus/console_libraries
install -m 755 consoles/aws_elasticache.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/aws_elb.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/aws_redshift-cluster.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/aws_redshift.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/blackbox.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/cassandra.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/cloudwatch.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/haproxy-backend.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/haproxy-backends.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/haproxy-frontend.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/haproxy-frontends.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/haproxy.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/index.html.example $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/node-cpu.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/node-disk.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/node-overview.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/node.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/prometheus-overview.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/prometheus.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/snmp-overview.html $RPM_BUILD_ROOT/opt/prometheus/consoles
install -m 755 consoles/snmp.html $RPM_BUILD_ROOT/opt/prometheus/consoles

%clean

%pre

%post

%files
%defattr(-,root,root,-)
/opt/prometheus/bin/prometheus
/opt/prometheus/bin/promtool
/opt/prometheus/consoles/aws_elasticache.html
/opt/prometheus/consoles/aws_elb.html
/opt/prometheus/consoles/aws_redshift-cluster.html
/opt/prometheus/consoles/aws_redshift.html
/opt/prometheus/consoles/blackbox.html
/opt/prometheus/consoles/cassandra.html
/opt/prometheus/consoles/cloudwatch.html
/opt/prometheus/consoles/haproxy-backend.html
/opt/prometheus/consoles/haproxy-backends.html
/opt/prometheus/consoles/haproxy-frontend.html
/opt/prometheus/consoles/haproxy-frontends.html
/opt/prometheus/consoles/haproxy.html
/opt/prometheus/consoles/index.html.example
/opt/prometheus/consoles/node-cpu.html
/opt/prometheus/consoles/node-disk.html
/opt/prometheus/consoles/node-overview.html
/opt/prometheus/consoles/node.html
/opt/prometheus/consoles/prometheus-overview.html
/opt/prometheus/consoles/prometheus.html
/opt/prometheus/consoles/snmp-overview.html
/opt/prometheus/consoles/snmp.html
/opt/prometheus/console_libraries/prom.lib
/opt/prometheus/console_libraries/menu.lib
