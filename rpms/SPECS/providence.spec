%global providence_git_revision 61b7872cf20a4acad120004ca2696fc8ced750f1


Name: providence
Version: 1.0.0
Release: 1%{?dist}
Summary: Code commit & bug system monitoring
Group: Applications/Internet
License: MIT
Source: https://git.soma.salesforce.com/AcqSec/providence.tar.gz
URL: https://git.soma.salesforce.com/AcqSec/Providence
BuildRequires: epel-release
BuildRequires: gcc 
BuildRequires: libffi-devel
BuildRequires: python-devel 
BuildRequires: openssl-devel
BuildRequires: python-pip
BuildRequires: python-virtualenv
BuildRoot: %{_tmppath}/%name-root


%description
A code commit & bug system monitoring
The source resides on soma so must be downloaded to the SOURCES directory and compressed into tar.gz format before install
git clone https://git.soma.salesforce.com/AcqSec/Providence.git --recursive (or it won't grab the Empires bits)

%prep

%setup

%build

%install
install -d -m 755 providence-1.0.0 /opt/

%files
%defattr(-,root,root,-)
/opt/providence-1.0.0

%clean
rm -rf $RPM_BUILD_ROOT
