Name: rmux
Version: 0.3.1.9
Release: 6%{?dist}
Summary: Redis multiplexer and connection pooling solution
Group: Applications/Internet
License: Salesforce
URL: https://github.com/SalesforceEng/rmux
Source0: https://github.com/SalesforceEng/rmux/archive/%{version}.tar.gz

BuildRequires: gcc
BuildRequires: golang >= 1.4

#BuildRoot: %{_tmppath}/%name-root

%description
Redis multiplexer and connection pooling solution

%prep
%setup -q -n rmux-%{version}
rm -rf vendor

%build
# set up temp gopath and put our directory there
mkdir -p ./_build/src/github.com/SalesforceEng
ln -s $(pwd) ./_build/src/github.com/SalesforceEng/rmux

export GOPATH=$(pwd)/_build:%{gopath}
go build -o rmux.amd64 github.com/SalesforceEng/rmux

%install
install -d -m 755 %{buildroot}%{_bindir}
install -p -m 0755 ./rmux.amd64 %{buildroot}%{_bindir}/rmux

%files
%defattr(-,root,root,-)
%{_bindir}/rmux

%clean
rm -rf $RPM_BUILD_ROOT
