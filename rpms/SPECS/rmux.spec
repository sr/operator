Name: rmux
Version: 0.3.3.2
Release: 1%{?dist}
Summary: Redis multiplexer and connection pooling solution
Group: Applications/Internet
License: Salesforce
URL: https://github.com/SalesforceEng/rmux
Source0: https://github.com/SalesforceEng/rmux/archive/%{version}.tar.gz

BuildRequires: gcc
BuildRequires: golang >= 1.5.0

%description
Redis multiplexer and connection pooling solution

%prep
%setup -q -n rmux-%{version}
rm -rf vendor

%build
# special function to work around a bug...
function gobuild { go build -a -ldflags "-B 0x$(head -c20 /dev/urandom|od -An -tx1|tr -d ' \n')" -v -x "$@"; }
# set up temp gopath and put our directory there
mkdir -p ./_build/src/github.com/SalesforceEng
ln -s $(pwd) ./_build/src/github.com/SalesforceEng/rmux

export GOPATH=$(pwd)/_build:%{gopath}
cd ./_build/src/github.com/SalesforceEng/rmux
gobuild -o build/rmux ./main

%install
install -d -m 755 %{buildroot}%{_bindir}
install -p -m 0755 ./build/rmux %{buildroot}%{_bindir}/rmux

%files
%defattr(-,root,root,-)
%{_bindir}/rmux
