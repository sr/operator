%global api_version 2.3.0

Name: ruby-2.3.0
Version: 2.3.0
Release: 1%{?dist}
Summary: An interpreter of object-oriented scripting language
Group: Development/Languages
License: BSD-2-Clause
URL: https://www.ruby-lang.org/
Source0: http://cache.ruby-lang.org/pub/ruby/2.3/ruby-%{version}.tar.gz
BuildRequires: autoconf
BuildRequires: gdbm-devel
BuildRequires: ncurses-devel
BuildRequires: libffi-devel
BuildRequires: openssl-devel
BuildRequires: libyaml-devel
BuildRequires: readline-devel
BuildRoot: %{_tmppath}/%name-root

%description
Ruby is the interpreted scripting language for quick and easy
object-oriented programming.  It has many features to process text
files and to do system management tasks (as in Perl).  It is simple,
straight-forward, and extensible.

%prep
%setup -q -n ruby-%{version}

%build
./configure \
  --with-out-ext=tcl --with-out-ext=tk \
  --prefix=/opt/rubies/ruby-%{version} \
  --exec-prefix=/opt/rubies/ruby-%{version}
make

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

# install bundler
GEM_HOME=$RPM_BUILD_ROOT/opt/rubies/ruby-%{version}/lib/ruby/gems/%{api_version} \
  $RPM_BUILD_ROOT/opt/rubies/ruby-%{version}/bin/ruby \
  -I $RPM_BUILD_ROOT/opt/rubies/ruby-%{version}/lib/ruby/%{api_version} \
  -I $RPM_BUILD_ROOT/opt/rubies/ruby-%{version}/lib/ruby/%{api_version}/%{_arch}-linux \
  $RPM_BUILD_ROOT/opt/rubies/ruby-%{version}/bin/gem install bundler -v 1.11.2

%files
%defattr(-,root,root,-)
/opt/rubies/ruby-%{version}

%clean
rm -rf $RPM_BUILD_ROOT
