%define vault_ver 0.6.1
%define bin_dir /usr/local/bin/

Summary: Tool for securely accessing secrets
Name: vault
Version: %{vault_ver}
Release: 1.pardot%{?dist}
Group: Applications/Engineering
License: MPLv2.0
URL: https://vaultproject.io/
Source0: https://releases.hashicorp.com/%{name}/%{version}/%{name}_%{version}_linux_amd64.zip

%description
Vault is a tool for securely accessing secrets. A secret is anything that you want to tightly control access to, such as API keys, passwords, certificates, and more.

%prep
%setup -q -c -n %{name}_%{version}

%install
mkdir -p %{buildroot}/%{bin_dir}
cp vault %{buildroot}/%{bin_dir}

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%attr(755, root, root) %{bin_dir}/vault
