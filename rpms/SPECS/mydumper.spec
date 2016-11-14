
Name:           mydumper
Version:        0.9.1
Release:        1.pardot%{?dist}
Summary:        A high-performance MySQL backup tool

Group:          Applications/Databases
License:        GPLv3+
URL:            http://www.mydumper.org/
Source0:        http://launchpad.net/mydumper/0.9/%{version}/+download/%{name}-%{version}.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires:  glib2-devel mysql-devel zlib-devel pcre-devel
BuildRequires:  cmake 

%description
Mydumper (aka. MySQL Data Dumper) is a high-performance multi-threaded backup
(and restore) toolset for MySQL and Drizzle.

The main developers originally worked as Support Engineers at MySQL
(one has moved to Facebook and another to SkySQL) and this is how they would
envisage mysqldump based on years of user feedback.

%prep
%setup -q

sed -e 's/-Werror//' -i CMakeLists.txt


%build
cmake -DCMAKE_INSTALL_PREFIX="%{_prefix}" .
make %{?_smp_mflags} VERBOSE=1


%install
rm -rf %{buildroot}

make install DESTDIR=%{buildroot}

rm -f %{buildroot}%{_datadir}/doc/%{name}/html/.buildinfo


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/mydumper
%{_bindir}/myloader

