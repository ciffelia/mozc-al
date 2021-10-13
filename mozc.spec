Name: mozc
Summary: Mozc for Amazon Linux 2
Version: 0.3.0
Release: 0%{?dist}
Group: Applications/Editors
License: BSD-3-Clause
URL: https://github.com/ciffelia/mozc-al
BuildArch: x86_64

%description
A set of prebuilt Mozc binaries for Amazon Linux 2.

%install
install -D --preserve-timestamps %{_sourcedir}/mozc_server                %{buildroot}/usr/lib/mozc/mozc_server
install -D --preserve-timestamps %{_sourcedir}/mozc_tool                  %{buildroot}/usr/lib/mozc/mozc_tool
install -D --preserve-timestamps %{_sourcedir}/mozc_renderer              %{buildroot}/usr/lib/mozc_renderer
install -D --preserve-timestamps %{_sourcedir}/ibus_mozc                  %{buildroot}/usr/lib/ibus-mozc/ibus-engine-mozc
install -D --preserve-timestamps %{_sourcedir}/mozc_emacs_helper          %{buildroot}/usr/bin/mozc_emacs_helper
install -D --preserve-timestamps %{_sourcedir}/product_icon_32bpp-128.png %{buildroot}/usr/share/ibus-mozc/product_icon.png
install -D --preserve-timestamps %{_sourcedir}/mozc.xml                   %{buildroot}/usr/share/ibus/component/mozc.xml

%clean
rm -rf %{buildroot}

%files
%defattr(0755,root,root)
/usr/lib/mozc/mozc_server
/usr/lib/mozc/mozc_tool
/usr/lib/mozc_renderer
/usr/lib/ibus-mozc/ibus-engine-mozc
/usr/bin/mozc_emacs_helper
%defattr(0644,root,root)
/usr/share/ibus-mozc/product_icon.png
/usr/share/ibus/component/mozc.xml
