%define build_date_version %(date +"%Y.%m.%d")
%define destination_directory /var/www/geoip/
Name:          pardot-geoip
Version:       %{build_date_version}
Release:       1%{?dist}
Summary:       Maxmind GeoIP files for the Pardot application
Group:         Development/Libraries
License:       Salesforce
Vendor:        Salesforce
URL:           http://www.maxmind.com
Source0:       GeoIP.conf
BuildArch:     noarch
BuildRoot:     %{_tmppath}/%name-root

BuildRequires: geoipupdate

%description
Maxmind GeoIP files required for the Pardot application.
# To build this RPM, you are going to have to copy our GeoIP.conf into SOURCES.
# It's in the secret place.

%prep
%setup -q -T -c
install -D -m644 %{SOURCE0} %{_build}/GeoIP.conf

%build
geoipupdate -d %{_build} -f %{_build}/GeoIP.conf

%clean
rm -rf ${buildroot}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
install -m 0755 -D %{_build}/GeoIPCity.dat %{buildroot}%{destination_directory}/GeoIPCity.dat
install -m 0755 -D %{_build}/GeoIPISP.dat %{buildroot}%{destination_directory}/GeoIPISP.dat
install -m 0755 -D %{_build}/GeoIPOrg.dat %{buildroot}%{destination_directory}/GeoIPOrg.dat

%files
%defattr(-,root,root,-)
%{destination_directory}/GeoIPCity.dat
%{destination_directory}/GeoIPISP.dat
%{destination_directory}/GeoIPOrg.dat
