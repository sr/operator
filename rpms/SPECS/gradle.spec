Name: gradle
Version: 1.3
Release: 1%{?dist}
Summary: Gradle is a modern open source polyglot build automation system.
Group: Applications/Internet
License: Apache
URL: http://gradle.org/
Source0: http://services.gradle.org/distributions/gradle-%{version}-bin.zip
BuildRoot: %{_tmppath}/%name-root
%define debug_package %{nil}

%description
Gradle is a build system that we think is a quantum leap for build technology in the Java (JVM) world. Gradle provides:
A very flexible general purpose build tool like Ant.
Switchable, build-by-convention frameworks a la Maven. But we never lock you in!
Very powerful support for multi-project builds.
Very powerful dependency management (based on Apache Ivy).
Full support for your existing Maven or Ivy repository infrastructure.
Support for transitive dependency management without the need for remote repositories or pom.xml and ivy.xml files.
Ant tasks and builds as first class citizens.
Groovy build scripts.
A rich domain model for describing your build.

%prep
%setup -q -n gradle-%{version}

%build

%install
rm -rf $RPM_BUILD_ROOT
install -d -m 755 $RPM_BUILD_ROOT/opt/gradle/gradle-%{version}
cp -rp * $RPM_BUILD_ROOT/opt/gradle/gradle-%{version}

%files
%defattr(-,root,root,-)
/opt/gradle/gradle-%{version}

%clean
rm -rf $RPM_BUILD_ROOT
