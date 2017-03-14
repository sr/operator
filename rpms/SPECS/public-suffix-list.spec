%define build_date_version %(date +"%Y.%m.%d")
%define destination_directory /var/www/mozilla/psl/

Name:          public-suffix-list
Version:       %{build_date_version}
Release:       1%{?dist}
Summary:       The Public Suffix List is a cross-vendor initiative to provide an accurate list of domain name suffixes.
Group:         Development/Libraries
License:       Mozilla Public License v2.0
Vendor:        Mozilla
URL:           https://publicsuffix.org
Source0:       https://publicsuffix.org/list/public_suffix_list.dat
BuildArch:     noarch
BuildRoot:     %{_tmppath}/%name-root

%description
The Public Suffix List is a cross-vendor initiative to provide an accurate list of domain name suffixes, maintained by the hard work of Mozilla volunteers and by submissions from registries, to whom we are very grateful.

%prep

%build

%clean
rm -rf %{buildroot}

%install
rm -rf %{buildroot}
install -d -m 0755 %{buildroot}/%{destination_directory}
install -m 0644 %{SOURCE0} %{buildroot}/%{destination_directory}/public_suffix_list.dat

%files
%defattr(-,root,root,-)
%{destination_directory}/public_suffix_list.dat
