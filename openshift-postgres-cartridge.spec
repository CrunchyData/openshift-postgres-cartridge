%global cartridgedir %{_libexecdir}/openshift/cartridges/crunchypg-cart

Summary:       Provides Crunchy Postgres support
Name:          openshift-postgres-cartridge
Version:       1.0.6
Release:       1%{?dist}
Group:         Development/Languages
License:       ASL 2.0
URL:           http://www.openshift.com
Source0:       file:///./%{name}-%{version}.tar.gz
Requires:      rubygem(openshift-origin-node)
Requires:      openshift-origin-node-util
Requires:      lsof
Requires:      bc
Requires:      /bin/sh

%description
Provides postgres support to OpenShift. (Cartridge Format V2)

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
%doc %{cartridgedir}/LICENSE

%changelog
* Mon Jun 16 2014 jeff mccormick <jeffmc04@gmail.com> 1.0.6-1
- update docs (jeffmc04@gmail.com)
- update with postgis and all contrib modules built in (jeffmc04@gmail.com)

* Mon Jun 16 2014 jeff mccormick <jeffmc04@gmail.com>
- update docs (jeffmc04@gmail.com)
- update with postgis and all contrib modules built in (jeffmc04@gmail.com)

* Tue Jun 10 2014 jeff mccormick <jeffmc04@gmail.com> 1.0.3-1
- fixed stop() function to report correct exit code
  (jeffmc@localhost.localdomain)
- update README (jeffmc@localhost.localdomain)
- fix (jeffmc@localhost.localdomain)
- Merge branch 'master' of github.com:crunchyds/openshift-postgres-cartridge
  (jeffmc@localhost.localdomain)
- fix setting of LD_LIBRARY_PATH for ose2.1 (jeffmc@localhost.localdomain)

* Tue May 13 2014 jeff mccormick <jeffmc04@gmail.com> 1.0.2-1
- 

* Tue May 13 2014 Unknown name 1.0.1-1
- new package built with tito

* Tue Mar 18 2014 Unknown name 0.0.6-1
- fix (jeffmc@localhost.localdomain)

* Tue Mar 18 2014 Unknown name 0.0.5-1
- fix (jeffmc@localhost.localdomain)

* Tue Mar 18 2014 Unknown name 0.0.4-1
- fixed (jeffmc@localhost.localdomain)

* Tue Mar 18 2014 Unknown name 0.0.3-1
- fix spec (jeffmc@localhost.localdomain)

* Tue Mar 18 2014 Unknown name 0.0.2-1
- new package built with tito

