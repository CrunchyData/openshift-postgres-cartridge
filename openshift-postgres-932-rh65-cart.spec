%global cartridgedir %{_libexecdir}/openshift/cartridges/crunchypg-cart

Summary:       Provides Crunchy Postgres 932 support
Name:          openshift-postgres-932-rh65-cart
Version:       0.0.3
Release:       1%{?dist}
Group:         Development/Languages
License:       ASL 2.0
URL:           http://www.openshift.com
Source0:       file:///./%{name}-%{version}.tar.gz
Requires:      rubygem(openshift-origin-node)
Requires:      openshift-origin-node-util
Requires:      lsof
Requires:      bc
BuildArch:     noarch

%description
Provides postgres 932 support to OpenShift. (Cartridge Format V2)

%prep
%setup -q

%build
%__rm %{name}.spec

%install
%__mkdir -p %{buildroot}%{cartridgedir}
%__cp -r * %{buildroot}%{cartridgedir}

%post

%{_sbindir}/oo-admin-cartridge --action install --source %{cartridgedir}


%files
%dir %{cartridgedir}
%attr(0755,-,-) %{cartridgedir}/bin/
%attr(0755,-,-) %{cartridgedir}/hooks/
%{cartridgedir}
%doc %{cartridgedir}/README.md
%doc %{cartridgedir}/COPYRIGHT
%doc %{cartridgedir}/LICENSE

%changelog
* Tue Mar 18 2014 Unknown name 0.0.3-1
- fix spec (jeffmc@localhost.localdomain)

* Tue Mar 18 2014 Unknown name 0.0.2-1
- new package built with tito

