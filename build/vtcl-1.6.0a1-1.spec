%define version 1.6.0a1

Summary:	Visual Tcl is an integrated development environment for Tcl/Tk 8.3 and later.
Name:		vtcl
Version:	%{version}
Release:	1
Icon:		title.gif
Copyright:	GPL
Group:	Applications
Source:	vtcl-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-buildroot
Requires:   tcl >= 8.3
Requires:   tk  >= 8.3
Prefix:     /opt

%description
Visual Tcl is a freely-available, cross-platform application development
environment for the Tcl/Tk language.

It generates pure Tcl/Tk code and has support for Itcl megawidgets, Tix,
TkTable, and the BLT extension.

Visual Tcl is covered by the GNU General Public License.
Please read the LICENSE file for more information.

%prep
%setup

%build
%install
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget/lang
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget/images
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/bwidget/
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/core
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/tix
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/user
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/vtcl
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/itcl
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/blt
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/table
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/doc
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo/images
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images/edit
mkdir -p $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/sample
install -m 644 opt/local/vtcl-%{version}/demo/README			    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo
install -m 644 opt/local/vtcl-%{version}/demo/*.tcl				    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo
install -m 644 opt/local/vtcl-%{version}/demo/*.ttd				    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo
install -m 644 opt/local/vtcl-%{version}/demo/*.html			    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo
install -m 644 opt/local/vtcl-%{version}/demo/images/*.gif		    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/demo/images
install -m 644 opt/local/vtcl-%{version}/doc/*.txt					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/doc
install -m 644 opt/local/vtcl-%{version}/doc/*.html					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/doc
install -m 644 opt/local/vtcl-%{version}/lib/Help/Main				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/lib/Help/Preferences		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/lib/Help/PropManager		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/lib/Help/WidgetTree		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/lib/Help/Tips				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/lib/Help/About.txt			$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Help
install -m 644 opt/local/vtcl-%{version}/images/edit/*.gif		    $RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images/edit
install -m 644 opt/local/vtcl-%{version}/images/*.gif				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images
install -m 644 opt/local/vtcl-%{version}/images/*.ppm				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images
install -m 644 opt/local/vtcl-%{version}/images/*.xbm				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images
install -m 644 opt/local/vtcl-%{version}/images/*.xpm				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/images
install -m 644 opt/local/vtcl-%{version}/lib/*.tcl					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib
install -m 644 opt/local/vtcl-%{version}/lib/bwidget/*.tcl				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget
install -m 644 opt/local/vtcl-%{version}/lib/bwidget/lang/*.rc				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget/lang
install -m 644 opt/local/vtcl-%{version}/lib/bwidget/images/*.gif			$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget/images
install -m 644 opt/local/vtcl-%{version}/lib/bwidget/images/*.xbm			$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/bwidget/images
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/table/*.wgt	$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/table
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/bwidget/*.wgt	$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/bwidget
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/bwidget/*.gif	$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/bwidget
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/core/*.wgt		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/core
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/tix/*.wgt		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/tix
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/vtcl/*.wgt		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/vtcl
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/itcl/*.wgt		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/itcl
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/itcl/*.gif		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/itcl
install -m 644 opt/local/vtcl-%{version}/lib/Widgets/blt/*.wgt		$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/lib/Widgets/blt
install -m 644 opt/local/vtcl-%{version}/sample/*.tcl				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/sample
install -m 644 opt/local/vtcl-%{version}/ChangeLog					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}
install -m 644 opt/local/vtcl-%{version}/LICENSE					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}
install -m 644 opt/local/vtcl-%{version}/README						$RPM_BUILD_ROOT/opt/local/vtcl-%{version}
install -m 755 opt/local/vtcl-%{version}/configure					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}
install -m 755 opt/local/vtcl-%{version}/vtcl.tcl 					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/vtcl.tcl
install -m 755 opt/local/vtcl-%{version}/vtsetup.tcl				$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/vtsetup.tcl
install -m 644 opt/local/vtcl-%{version}/vtclmac					$RPM_BUILD_ROOT/opt/local/vtcl-%{version}/vtclmac

%files
/opt/local/vtcl-%{version}

%clean
rm -rf $RPM_BUILD_ROOT

%post
$RPM_INSTALL_PREFIX/local/vtcl-%{version}/configure

%preun
rm -f $RPM_INSTALL_PREFIX/local/vtcl-%{version}/vtcl
