%global providence_git_revision 61b7872cf20a4acad120004ca2696fc8ced750f1

Name: providence
Version: 1.0.0
Release: 1%{?dist}
Summary: Code commit & bug system monitoring
Group: Applications/Internet
License: MIT
# 1. git clone --recurse-submodules https://git.soma.salesforce.com/AcqSec/Providence providence
# 2. tar --exclude='.git' -cvzf /path/to/rpms/SOURCES/providence.tar.gz providence
Source: providence.tar.gz
URL: https://git.soma.salesforce.com/AcqSec/Providence
BuildRequires: epel-release
BuildRequires: gcc
BuildRequires: libffi-devel
BuildRequires: python-devel
BuildRequires: openssl-devel
BuildRequires: python-pip
BuildRequires: python-virtualenv
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
A code commit & bug system monitoring
The source resides on soma so must be downloaded to the SOURCES directory and compressed into tar.gz format before install
git clone https://git.soma.salesforce.com/AcqSec/Providence.git --recursive (or it won't grab the Empires bits)

%prep
%setup -q -n providence

%build

%install
install -d -m 0755 $RPM_BUILD_ROOT/opt/providence
cp -r . $RPM_BUILD_ROOT/opt/providence

%files
%defattr(-,root,root,-)
/opt/providence

%clean
rm -rf $RPM_BUILD_ROOT
