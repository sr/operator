%global mod_realdoc_git_revision 1f9cbeda1b5e037fc9e460b437a884e9e9a4f4ae

Name: mod_realdoc
Version: 1.0.0
Release: 1%{?dist}
Summary: Apache module to support atomic deploys
Group: Applications/Internet
License: MIT
URL: https://github.com/etsy/mod_realdoc
Source0: https://github.com/etsy/mod_realdoc/archive/%{mod_realdoc_git_revision}.tar.gz
BuildRequires: httpd-devel
BuildRequires: httpd-devel
BuildRoot: %{_tmppath}/%name-root

%description
mod_realdoc is an Apache module which does a realdoc on the docroot symlink and
sets the absolute path as the real document root for the remainder of the
request.

%prep
%setup -q -n mod_realdoc-%{mod_realdoc_git_revision}

%build
/usr/sbin/apxs -c mod_realdoc.c

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/%{_libdir}/httpd/modules
install -m 755 .libs/mod_realdoc.so $RPM_BUILD_ROOT/%{_libdir}/httpd/modules

%files
%defattr(-,root,root,-)
%{_libdir}/httpd/modules/mod_realdoc.so

%clean
rm -rf $RPM_BUILD_ROOT
