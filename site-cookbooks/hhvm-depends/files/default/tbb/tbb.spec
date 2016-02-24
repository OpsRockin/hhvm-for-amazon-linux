%global releasedate 20160128
%global major 4
%global minor 4
%global update 3
%global dotver %{major}.%{minor}
%global sourcebasename tbb%{major}%{minor}_%{releasedate}oss

%global sourcefilename %{sourcebasename}_src.tgz

Name:    tbb
Summary: The Threading Building Blocks library abstracts low-level threading details
Version: %{dotver}
Release: 3.%{releasedate}%{?dist}
License: GPLv2 with exceptions
Group:   Development/Tools
URL:     http://threadingbuildingblocks.org/

Source0: http://threadingbuildingblocks.org/sites/default/files/software_releases/source/%{sourcebasename}_src.tgz
# These two are downstream sources.
Source6: tbb.pc
Source7: tbbmalloc.pc
Source8: tbbmalloc_proxy.pc

# Propagate CXXFLAGS variable into flags used when compiling C++.
# This is so that RPM_OPT_FLAGS are respected.
Patch1: tbb-4.4-cxxflags.patch

# For 32-bit x86 only, don't assume that the mfence instruction is available.
# It was added with SSE2.  This patch causes a lock xchg instruction to be
# emitted for non-SSE2 builds, and the mfence instruction to be emitted for
# SSE2-enabled builds.
Patch2: tbb-4.0-mfence.patch

# Don't snip -Wall from C++ flags.  Add -fno-strict-aliasing, as that
# uncovers some static-aliasing warnings.
# Related: https://bugzilla.redhat.com/show_bug.cgi?id=1037347
Patch3: tbb-4.3-dont-snip-Wall.patch

# Upstream: 20 Feb 2016.  Fix a min macro that clashes with std::min.
Patch4: tbb-4.4-min.patch

BuildRequires: gcc-c++

%description
Threading Building Blocks (TBB) is a C++ runtime library that
abstracts the low-level threading details necessary for optimal
multi-core performance.  It uses common C++ templates and coding style
to eliminate tedious threading implementation work.

TBB requires fewer lines of code to achieve parallelism than other
threading models.  The applications you write are portable across
platforms.  Since the library is also inherently scalable, no code
maintenance is required as more processor cores become available.


%package devel
Summary: The Threading Building Blocks C++ headers and shared development libraries
Group: Development/Libraries
Requires: %{name}%{?_isa} = %{version}-%{release}

%description devel
Header files and shared object symlinks for the Threading Building
Blocks (TBB) C++ libraries.


%package doc
Summary: The Threading Building Blocks documentation
Group: Documentation
Provides: bundled(jquery)

%description doc
PDF documentation for the user of the Threading Building Block (TBB)
C++ library.


%prep
%setup -q -n %{sourcebasename}
%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1

# For repeatable builds, don't query the hostname or architecture
sed -i 's/`hostname -s`" ("`uname -m`/fedorabuild" ("%{_arch}/' \
    build/version_info_linux.sh

%build
%ifarch %{ix86}
# Build an SSE2-enabled version so the mfence instruction can be used
cp -a build build.orig
make %{?_smp_mflags} CXXFLAGS="$RPM_OPT_FLAGS -march=pentium4 -msse2" \
  tbb_build_prefix=obj cpp0x=1
mv build build.sse2
mv build.orig build
%endif

make %{?_smp_mflags} CXXFLAGS="$RPM_OPT_FLAGS" tbb_build_prefix=obj cpp0x=1
for file in %{SOURCE6} %{SOURCE7} %{SOURCE8}; do
    base=$(basename ${file})
    sed 's/_FEDORA_VERSION/%{major}.%{minor}.%{update}/' ${file} > ${base}
    touch -r ${file} ${base}
done

%check
%ifarch ppc64le
make test CXXFLAGS="$RPM_OPT_FLAGS" cpp0x=1
%endif

%install
mkdir -p $RPM_BUILD_ROOT/%{_libdir}
mkdir -p $RPM_BUILD_ROOT/%{_includedir}

%ifarch %{ix86}
mkdir -p $RPM_BUILD_ROOT/%{_libdir}/sse2
pushd build.sse2/obj_release
    for file in libtbb{,malloc{,_proxy}}; do
        install -p -D -m 755 ${file}.so.2 $RPM_BUILD_ROOT/%{_libdir}/sse2
    done
popd
%endif

pushd build/obj_release
    for file in libtbb{,malloc{,_proxy}}; do
        install -p -D -m 755 ${file}.so.2 $RPM_BUILD_ROOT/%{_libdir}
        ln -s $file.so.2 $RPM_BUILD_ROOT/%{_libdir}/$file.so
    done
popd

pushd include
    find tbb -type f ! -name \*.htm\* -exec \
        install -p -D -m 644 {} $RPM_BUILD_ROOT/%{_includedir}/{} \
    \;
popd

for file in %{SOURCE6} %{SOURCE7} %{SOURCE8}; do
    install -p -D -m 644 $(basename ${file}) \
	$RPM_BUILD_ROOT/%{_libdir}/pkgconfig/$(basename ${file})
done

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%doc COPYING doc/Release_Notes.txt
%{_libdir}/*.so.2
%ifarch %{ix86}
%{_libdir}/sse2/*.so.2
%endif

%files devel
%doc CHANGES
%{_includedir}/tbb
%{_libdir}/*.so
%{_libdir}/pkgconfig/*.pc

%files doc
%doc doc/Release_Notes.txt
%doc doc/html

%changelog
* Sat Feb 20 2016 Jerry James <loganjerry@gmail.com> - 4.4-3.20160128
- Rebase to 4.4u3

* Fri Feb 05 2016 Fedora Release Engineering <releng@fedoraproject.org> - 4.4-2.20151115
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Fri Jan 15 2016 Jerry James <loganjerry@gmail.com> - 4.4-1.20151115
- Rebase to 4.4u2
- Fix the mfence patch to actually emit a memory barrier (bz 1288314)
- Build an sse2 version for i386 for better performance on capable CPUs
- Enable use of C++0x features
- Drop out-of-date CHANGES.txt from git

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.3-3.20141204
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Sat May 02 2015 Kalev Lember <kalevlember@gmail.com> - 4.3-2.20141204
- Rebuilt for GCC 5 C++11 ABI change

* Mon Jan 19 2015 Petr Machata <pmachata@redhat.com> - 4.3-1.20141204
- Rebase to 4.3u2
- Drop ExclusiveArch

* Thu Sep 25 2014 Karsten Hopp <karsten@redhat.com> 4.1-9.20130314
- enable ppc64le and run 'make test' on that new arch

* Mon Aug 18 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.1-8.20130314
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.1-7.20130314
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Sun Jan 12 2014 Peter Robinson <pbrobinson@fedoraproject.org> 4.1-6.20130314
- Build on aarch64, minor spec cleanups

* Tue Dec  3 2013 Petr Machata <pmachata@redhat.com> - 4.1-5.20130314
- Fix building with -Werror=format-security (tbb-4.1-dont-snip-Wall.patch)

* Thu Oct  3 2013 Petr Machata <pmachata@redhat.com> - 4.1-4.20130314
- Fix %%install to also install include files that are not named *.h

* Sun Aug 04 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.1-3.20130314
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Tue May 28 2013 Petr Machata <pmachata@redhat.com> - 4.1-3.20130314
- Enable ARM arches

* Wed May 22 2013 Petr Machata <pmachata@redhat.com> - 4.1-2.20130314
- Fix mfence patch.  Since the __TBB_full_memory_fence macro was
  function-call-like, it stole () intended for function invocation.

* Wed May 22 2013 Petr Machata <pmachata@redhat.com> - 4.1-1.20130314
- Rebase to 4.1 update 3

* Fri Feb 15 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.0-7.20120408
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Tue Aug 28 2012 Petr Machata <pmachata@redhat.com> - 4.0-6.20120408
- Fix build on PowerPC

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.0-5.20120408
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Thu Jun  7 2012 Petr Machata <pmachata@redhat.com> - 4.0-4.20120408
- Rebase to 4.0 update 4
- Refresh Getting_Started.pdf, Reference.pdf, Tutorial.pdf
- Provide pkg-config files
- Resolves: #825402

* Thu Apr 05 2012 Karsten Hopp <karsten@redhat.com> 4.0-3.20110809
- tbb builds now on PPC(64)

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.0-2.20110809
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Oct 18 2011 Petr Machata <pmachata@redhat.com> - 4.0-1.20110809
- Rebase to 4.0
  - Port the mfence patch
  - Refresh the documentation bundle

* Tue Jul 26 2011 Petr Machata <pmachata@redhat.com> - 3.0-1.20110419
- Rebase to 3.0-r6
  - Port both patches
  - Package Design_Patterns.pdf
  - Thanks to Richard Shaw for initial rebase patch
- Resolves: #723043

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.2-3.20090809
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Thu Jun 10 2010 Petr Machata <pmachata@redhat.com> - 2.2-2.20090809
- Replace mfence instruction with xchg to make it run on ia32-class
  machines without SSE2.
- Resolves: #600654

* Tue Nov  3 2009 Petr Machata <pmachata@redhat.com> - 2.2-1.20090809
- New upstream 2.2
- Resolves: #521571

* Sun Jul 26 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.1-3.20080605
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Feb 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.1-2.20080605
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Fri Jun 13 2008 Petr Machata <pmachata@redhat.com> - 2.1-1.20080605
- New upstream 2.1
  - Drop soname patch, parallel make patch, and GCC 4.3 patch

* Wed Feb 13 2008 Petr Machata <pmachata@redhat.com> - 2.0-4.20070927
- Review fixes
  - Use updated URL
  - More timestamp preservation
- Initial import into Fedora CVS

* Mon Feb 11 2008 Petr Machata <pmachata@redhat.com> - 2.0-3.20070927
- Review fixes
  - Preserve timestamp of installed files
  - Fix soname not to contain "debug"

* Tue Feb  5 2008 Petr Machata <pmachata@redhat.com> - 2.0-2.20070927
- Review fixes
  - GCC 4.3 patchset
  - Add BR util-linux net-tools
  - Add full URL to Source0
  - Build in debug mode to work around problems with GCC 4.3

* Mon Dec 17 2007 Petr Machata <pmachata@redhat.com> - 2.0-1.20070927
- Initial package.
- Using SONAME patch from Debian.
