%define version 1.2.2

Summary:	Visual Tcl is an integrated development environment for Tcl/Tk 8.0 and later.
Name:		vtcl
Version:	%{version}
Release:	1
Icon:		title.gif
Copyright:	GPL
Group:	Applications
Source:	vtcl-%{version}.tar.gz
BuildRoot: /var/tmp/%{name}-buildroot

%description
Visual Tcl is a freely-available, cross-platform application development environment
for the Tcl/Tk language. It generates pure Tcl/Tk code and has support for Itcl megawidgets
and the BLT extension.

Visual Tcl is covered by the GNU General Public License.
Please read the LICENSE file for more information.

%prep
%setup

%build
%install
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/doc
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/images
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample
install -m 644 usr/local/vtcl-%{version}/demo/combo.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/combo.tcl
install -m 644 usr/local/vtcl-%{version}/demo/README			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/README
install -m 644 usr/local/vtcl-%{version}/demo/images/free.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/images/free.gif
install -m 644 usr/local/vtcl-%{version}/demo/images/line.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/images/line.gif
install -m 644 usr/local/vtcl-%{version}/demo/images/oval.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/images/oval.gif
install -m 644 usr/local/vtcl-%{version}/demo/images/rect.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/images/rect.gif
install -m 644 usr/local/vtcl-%{version}/demo/draw.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/draw.tcl
install -m 644 usr/local/vtcl-%{version}/demo/ex1_cmpd.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/ex1_cmpd.tcl
install -m 644 usr/local/vtcl-%{version}/demo/grid.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/grid.tcl
install -m 644 usr/local/vtcl-%{version}/demo/simple.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/simple.tcl
install -m 644 usr/local/vtcl-%{version}/demo/tclet-combo.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/tclet-combo.tcl
install -m 644 usr/local/vtcl-%{version}/demo/tclet-draw.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/tclet-draw.tcl
install -m 644 usr/local/vtcl-%{version}/demo/tclet-grid.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/tclet-grid.tcl
install -m 644 usr/local/vtcl-%{version}/demo/tclet-simple.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/tclet-simple.tcl
install -m 644 usr/local/vtcl-%{version}/demo/tclets.html		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/demo/tclets.html
install -m 644 usr/local/vtcl-%{version}/doc/tutorial.txt		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/doc/tutorial.txt
install -m 644 usr/local/vtcl-%{version}/images/edit/copy.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/copy.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/cut.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/cut.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/icons.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/icons.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/new.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/new.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/open.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/open.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/paste.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/paste.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/replace.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/replace.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/save.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/save.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/search.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/search.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/srchbak.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/srchbak.gif
install -m 644 usr/local/vtcl-%{version}/images/edit/srchfwd.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/edit/srchfwd.gif
install -m 644 usr/local/vtcl-%{version}/images/anchor.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor.gif
install -m 644 usr/local/vtcl-%{version}/images/anchor_c.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_c.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_e.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_e.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_n.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_n.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_ne.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_ne.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_nw.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_nw.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_s.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_s.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_se.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_se.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_sw.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_sw.ppm
install -m 644 usr/local/vtcl-%{version}/images/anchor_w.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/anchor_w.ppm
install -m 644 usr/local/vtcl-%{version}/images/bg.gif			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/bg.gif
install -m 644 usr/local/vtcl-%{version}/images/border.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/border.gif
install -m 644 usr/local/vtcl-%{version}/images/curse.xbm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/curse.xbm
install -m 644 usr/local/vtcl-%{version}/images/down.xbm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/down.xbm
install -m 644 usr/local/vtcl-%{version}/images/ellipses.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/ellipses.gif
install -m 644 usr/local/vtcl-%{version}/images/fg.gif			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/fg.gif
install -m 644 usr/local/vtcl-%{version}/images/fontbase.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/fontbase.gif
install -m 644 usr/local/vtcl-%{version}/images/fontsize.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/fontsize.gif
install -m 644 usr/local/vtcl-%{version}/images/fontstyle.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/fontstyle.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_button.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_button.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_buttonbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_buttonbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_calendar.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_calendar.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_canvas.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_canvas.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_checkbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_checkbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_checkbutton.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_checkbutton.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_combobox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_combobox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_dateentry.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_dateentry.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_entry.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_entry.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_entryfield.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_entryfield.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_feedback.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_feedback.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_frame.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_frame.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_graph.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_graph.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_hierarchy.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_hierarchy.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_hierbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_hierbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_label.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_label.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_listbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_listbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_mclistbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_mclistbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_menu.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_menu.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_menubutton.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_menubutton.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_message.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_message.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_optionmenu.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_optionmenu.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_radiobox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_radiobox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_radiobutton.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_radiobutton.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scale_h.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scale_h.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scale_v.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scale_v.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scrollbar_h.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scrollbar_h.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scrollbar_v.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scrollbar_v.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scrolledhtml.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scrolledhtml.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scrolledlistbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scrolledlistbox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_scrolledtext.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_scrolledtext.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_spinint.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_spinint.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_stripchart.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_stripchart.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_text.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_text.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixComboBox.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixComboBox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixFileEntry.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixFileEntry.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixLabelEntry.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixLabelEntry.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixLabelFrame.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixLabelFrame.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixMeter.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixMeter.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixNoteBook.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixNoteBook.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixOptionMenu.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixOptionMenu.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixPanedWindow.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixPanedWindow.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixScrolledHList.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixScrolledHList.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixScrolledListBox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixScrolledListBox.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixSelect.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixSelect.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tixTree.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tixTree.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_tix_unknown.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_tix_unknown.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_toolbar.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_toolbar.gif
install -m 644 usr/local/vtcl-%{version}/images/icon_toplevel.gif	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/icon_toplevel.gif
install -m 644 usr/local/vtcl-%{version}/images/justify.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/justify.gif
install -m 644 usr/local/vtcl-%{version}/images/mgr_grid.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/mgr_grid.gif
install -m 644 usr/local/vtcl-%{version}/images/mgr_pack.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/mgr_pack.gif
install -m 644 usr/local/vtcl-%{version}/images/mgr_place.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/mgr_place.gif
install -m 644 usr/local/vtcl-%{version}/images/mini-vtcl.xpm		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/mini-vtcl.xpm
install -m 644 usr/local/vtcl-%{version}/images/ofg.gif			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/ofg.gif
install -m 644 usr/local/vtcl-%{version}/images/rel_groove.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/rel_groove.gif
install -m 644 usr/local/vtcl-%{version}/images/rel_raised.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/rel_raised.gif
install -m 644 usr/local/vtcl-%{version}/images/rel_ridge.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/rel_ridge.gif
install -m 644 usr/local/vtcl-%{version}/images/rel_sunken.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/rel_sunken.gif
install -m 644 usr/local/vtcl-%{version}/images/relief.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/relief.gif
install -m 644 usr/local/vtcl-%{version}/images/title.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/title.gif
install -m 644 usr/local/vtcl-%{version}/images/unknown.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/unknown.gif
install -m 644 usr/local/vtcl-%{version}/images/tconsole.gif		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/images/tconsole.gif
install -m 644 usr/local/vtcl-%{version}/lib/Makefile			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/Makefile
install -m 644 usr/local/vtcl-%{version}/lib/about.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/about.tcl
install -m 644 usr/local/vtcl-%{version}/lib/attrbar.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/attrbar.tcl
install -m 644 usr/local/vtcl-%{version}/lib/balloon.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/balloon.tcl
install -m 644 usr/local/vtcl-%{version}/lib/bind.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/bind.tcl
install -m 644 usr/local/vtcl-%{version}/lib/color.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/color.tcl
install -m 644 usr/local/vtcl-%{version}/lib/command.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/command.tcl
install -m 644 usr/local/vtcl-%{version}/lib/compound.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/compound.tcl
install -m 644 usr/local/vtcl-%{version}/lib/compounds.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/compounds.tcl
install -m 644 usr/local/vtcl-%{version}/lib/console.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/console.tcl
install -m 644 usr/local/vtcl-%{version}/lib/do.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/do.tcl
install -m 644 usr/local/vtcl-%{version}/lib/dragsize.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/dragsize.tcl
install -m 644 usr/local/vtcl-%{version}/lib/dump.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/dump.tcl
install -m 644 usr/local/vtcl-%{version}/lib/edit.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/edit.tcl
install -m 644 usr/local/vtcl-%{version}/lib/editor.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/editor.tcl
install -m 644 usr/local/vtcl-%{version}/lib/file.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/file.tcl
install -m 644 usr/local/vtcl-%{version}/lib/font.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/font.tcl
install -m 644 usr/local/vtcl-%{version}/lib/globals.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/globals.tcl
install -m 644 usr/local/vtcl-%{version}/lib/handle.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/handle.tcl
install -m 644 usr/local/vtcl-%{version}/lib/help.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/help.tcl
install -m 644 usr/local/vtcl-%{version}/lib/images.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/images.tcl
install -m 644 usr/local/vtcl-%{version}/lib/input.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/input.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_blt.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_blt.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_core.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_core.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_itcl.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_itcl.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_mclistbox.tcl       	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_mclistbox.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_tcombobox.tcl       	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_tcombobox.tcl
install -m 644 usr/local/vtcl-%{version}/lib/lib_tix.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/lib_tix.tcl
install -m 644 usr/local/vtcl-%{version}/lib/menu.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/menu.tcl
install -m 644 usr/local/vtcl-%{version}/lib/misc.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/misc.tcl
install -m 644 usr/local/vtcl-%{version}/lib/name.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/name.tcl
install -m 644 usr/local/vtcl-%{version}/lib/prefs.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/prefs.tcl
install -m 644 usr/local/vtcl-%{version}/lib/proc.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/proc.tcl
install -m 644 usr/local/vtcl-%{version}/lib/propmgr.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/propmgr.tcl
install -m 644 usr/local/vtcl-%{version}/lib/remove.sh			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/remove.sh
install -m 644 usr/local/vtcl-%{version}/lib/tabpanel.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/tabpanel.tcl
install -m 644 usr/local/vtcl-%{version}/lib/tclet.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/tclet.tcl
install -m 644 usr/local/vtcl-%{version}/lib/toolbar.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/toolbar.tcl
install -m 644 usr/local/vtcl-%{version}/lib/tops.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/tops.tcl
install -m 644 usr/local/vtcl-%{version}/lib/tree.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/tree.tcl
install -m 644 usr/local/vtcl-%{version}/lib/var.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/var.tcl
install -m 644 usr/local/vtcl-%{version}/lib/vtclib.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/vtclib.tcl
install -m 644 usr/local/vtcl-%{version}/lib/widget.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/lib/widget.tcl
install -m 644 usr/local/vtcl-%{version}/sample/User_Compound.tcl	$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample/User_Compound.tcl
install -m 644 usr/local/vtcl-%{version}/sample/hierarchy.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample/hierarchy.tcl
install -m 644 usr/local/vtcl-%{version}/sample/notebook.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample/notebook.tcl
install -m 644 usr/local/vtcl-%{version}/sample/panedwindow.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample/panedwindow.tcl
install -m 644 usr/local/vtcl-%{version}/sample/sampleBLT.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/sample/sampleBLT.tcl
install -m 644 usr/local/vtcl-%{version}/ChangeLog			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/ChangeLog
install -m 644 usr/local/vtcl-%{version}/LICENSE			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/LICENSE
install -m 644 usr/local/vtcl-%{version}/README				$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/README
install -m 755 usr/local/vtcl-%{version}/vt.tcl 			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/vt.tcl
install -m 755 usr/local/vtcl-%{version}/vtsetup.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/vtsetup.tcl
install -m 755 usr/local/vtcl-%{version}/vtcl 				$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/vtcl
install -m 644 usr/local/vtcl-%{version}/vtclmac			$RPM_BUILD_ROOT/usr/local/vtcl-%{version}/vtclmac

%files
/usr/local/vtcl-%{version}/vt.tcl
/usr/local/vtcl-%{version}/vtsetup.tcl
/usr/local/vtcl-%{version}/demo/combo.tcl
/usr/local/vtcl-%{version}/demo/README
/usr/local/vtcl-%{version}/demo/images/free.gif
/usr/local/vtcl-%{version}/demo/images/line.gif
/usr/local/vtcl-%{version}/demo/images/oval.gif
/usr/local/vtcl-%{version}/demo/images/rect.gif
/usr/local/vtcl-%{version}/demo/draw.tcl
/usr/local/vtcl-%{version}/demo/ex1_cmpd.tcl
/usr/local/vtcl-%{version}/demo/grid.tcl
/usr/local/vtcl-%{version}/demo/simple.tcl
/usr/local/vtcl-%{version}/demo/tclet-combo.tcl
/usr/local/vtcl-%{version}/demo/tclet-draw.tcl
/usr/local/vtcl-%{version}/demo/tclet-grid.tcl
/usr/local/vtcl-%{version}/demo/tclet-simple.tcl
/usr/local/vtcl-%{version}/demo/tclets.html
/usr/local/vtcl-%{version}/doc/tutorial.txt
/usr/local/vtcl-%{version}/images/edit/copy.gif
/usr/local/vtcl-%{version}/images/edit/cut.gif
/usr/local/vtcl-%{version}/images/edit/icons.gif
/usr/local/vtcl-%{version}/images/edit/new.gif
/usr/local/vtcl-%{version}/images/edit/open.gif
/usr/local/vtcl-%{version}/images/edit/paste.gif
/usr/local/vtcl-%{version}/images/edit/replace.gif
/usr/local/vtcl-%{version}/images/edit/save.gif
/usr/local/vtcl-%{version}/images/edit/search.gif
/usr/local/vtcl-%{version}/images/edit/srchbak.gif
/usr/local/vtcl-%{version}/images/edit/srchfwd.gif
/usr/local/vtcl-%{version}/images/anchor.gif
/usr/local/vtcl-%{version}/images/anchor_c.ppm
/usr/local/vtcl-%{version}/images/anchor_e.ppm
/usr/local/vtcl-%{version}/images/anchor_n.ppm
/usr/local/vtcl-%{version}/images/anchor_ne.ppm
/usr/local/vtcl-%{version}/images/anchor_nw.ppm
/usr/local/vtcl-%{version}/images/anchor_s.ppm
/usr/local/vtcl-%{version}/images/anchor_se.ppm
/usr/local/vtcl-%{version}/images/anchor_sw.ppm
/usr/local/vtcl-%{version}/images/anchor_w.ppm
/usr/local/vtcl-%{version}/images/bg.gif
/usr/local/vtcl-%{version}/images/border.gif
/usr/local/vtcl-%{version}/images/curse.xbm
/usr/local/vtcl-%{version}/images/down.xbm
/usr/local/vtcl-%{version}/images/ellipses.gif
/usr/local/vtcl-%{version}/images/fg.gif
/usr/local/vtcl-%{version}/images/fontbase.gif
/usr/local/vtcl-%{version}/images/fontsize.gif
/usr/local/vtcl-%{version}/images/fontstyle.gif
/usr/local/vtcl-%{version}/images/icon_button.gif
/usr/local/vtcl-%{version}/images/icon_buttonbox.gif
/usr/local/vtcl-%{version}/images/icon_calendar.gif
/usr/local/vtcl-%{version}/images/icon_canvas.gif
/usr/local/vtcl-%{version}/images/icon_checkbox.gif
/usr/local/vtcl-%{version}/images/icon_checkbutton.gif
/usr/local/vtcl-%{version}/images/icon_combobox.gif
/usr/local/vtcl-%{version}/images/icon_dateentry.gif
/usr/local/vtcl-%{version}/images/icon_entry.gif
/usr/local/vtcl-%{version}/images/icon_entryfield.gif
/usr/local/vtcl-%{version}/images/icon_feedback.gif
/usr/local/vtcl-%{version}/images/icon_frame.gif
/usr/local/vtcl-%{version}/images/icon_graph.gif
/usr/local/vtcl-%{version}/images/icon_hierarchy.gif
/usr/local/vtcl-%{version}/images/icon_hierbox.gif
/usr/local/vtcl-%{version}/images/icon_label.gif
/usr/local/vtcl-%{version}/images/icon_listbox.gif
/usr/local/vtcl-%{version}/images/icon_mclistbox.gif
/usr/local/vtcl-%{version}/images/icon_menu.gif
/usr/local/vtcl-%{version}/images/icon_menubutton.gif
/usr/local/vtcl-%{version}/images/icon_message.gif
/usr/local/vtcl-%{version}/images/icon_optionmenu.gif
/usr/local/vtcl-%{version}/images/icon_radiobox.gif
/usr/local/vtcl-%{version}/images/icon_radiobutton.gif
/usr/local/vtcl-%{version}/images/icon_scale_h.gif
/usr/local/vtcl-%{version}/images/icon_scale_v.gif
/usr/local/vtcl-%{version}/images/icon_scrollbar_h.gif
/usr/local/vtcl-%{version}/images/icon_scrollbar_v.gif
/usr/local/vtcl-%{version}/images/icon_scrolledhtml.gif
/usr/local/vtcl-%{version}/images/icon_scrolledlistbox.gif
/usr/local/vtcl-%{version}/images/icon_scrolledtext.gif
/usr/local/vtcl-%{version}/images/icon_spinint.gif
/usr/local/vtcl-%{version}/images/icon_stripchart.gif
/usr/local/vtcl-%{version}/images/icon_text.gif
/usr/local/vtcl-%{version}/images/icon_tixComboBox.gif
/usr/local/vtcl-%{version}/images/icon_tixFileEntry.gif
/usr/local/vtcl-%{version}/images/icon_tixLabelEntry.gif
/usr/local/vtcl-%{version}/images/icon_tixLabelFrame.gif
/usr/local/vtcl-%{version}/images/icon_tixMeter.gif
/usr/local/vtcl-%{version}/images/icon_tixNoteBook.gif
/usr/local/vtcl-%{version}/images/icon_tixOptionMenu.gif
/usr/local/vtcl-%{version}/images/icon_tixPanedWindow.gif
/usr/local/vtcl-%{version}/images/icon_tixScrolledHList.gif
/usr/local/vtcl-%{version}/images/icon_tixScrolledListBox.gif
/usr/local/vtcl-%{version}/images/icon_tixSelect.gif
/usr/local/vtcl-%{version}/images/icon_tixTree.gif
/usr/local/vtcl-%{version}/images/icon_tix_unknown.gif
/usr/local/vtcl-%{version}/images/icon_toolbar.gif
/usr/local/vtcl-%{version}/images/icon_toplevel.gif
/usr/local/vtcl-%{version}/images/justify.gif
/usr/local/vtcl-%{version}/images/mgr_grid.gif
/usr/local/vtcl-%{version}/images/mgr_pack.gif
/usr/local/vtcl-%{version}/images/mgr_place.gif
/usr/local/vtcl-%{version}/images/mini-vtcl.xpm
/usr/local/vtcl-%{version}/images/ofg.gif
/usr/local/vtcl-%{version}/images/rel_groove.gif
/usr/local/vtcl-%{version}/images/rel_raised.gif
/usr/local/vtcl-%{version}/images/rel_ridge.gif
/usr/local/vtcl-%{version}/images/rel_sunken.gif
/usr/local/vtcl-%{version}/images/relief.gif
/usr/local/vtcl-%{version}/images/title.gif
/usr/local/vtcl-%{version}/images/tconsole.gif
/usr/local/vtcl-%{version}/images/unknown.gif
/usr/local/vtcl-%{version}/lib/Makefile
/usr/local/vtcl-%{version}/lib/about.tcl
/usr/local/vtcl-%{version}/lib/attrbar.tcl
/usr/local/vtcl-%{version}/lib/balloon.tcl
/usr/local/vtcl-%{version}/lib/bind.tcl
/usr/local/vtcl-%{version}/lib/color.tcl
/usr/local/vtcl-%{version}/lib/command.tcl
/usr/local/vtcl-%{version}/lib/compound.tcl
/usr/local/vtcl-%{version}/lib/compounds.tcl
/usr/local/vtcl-%{version}/lib/console.tcl
/usr/local/vtcl-%{version}/lib/do.tcl
/usr/local/vtcl-%{version}/lib/dragsize.tcl
/usr/local/vtcl-%{version}/lib/dump.tcl
/usr/local/vtcl-%{version}/lib/edit.tcl
/usr/local/vtcl-%{version}/lib/editor.tcl
/usr/local/vtcl-%{version}/lib/file.tcl
/usr/local/vtcl-%{version}/lib/font.tcl
/usr/local/vtcl-%{version}/lib/globals.tcl
/usr/local/vtcl-%{version}/lib/handle.tcl
/usr/local/vtcl-%{version}/lib/help.tcl
/usr/local/vtcl-%{version}/lib/images.tcl
/usr/local/vtcl-%{version}/lib/input.tcl
/usr/local/vtcl-%{version}/lib/lib_blt.tcl
/usr/local/vtcl-%{version}/lib/lib_core.tcl
/usr/local/vtcl-%{version}/lib/lib_itcl.tcl
/usr/local/vtcl-%{version}/lib/lib_mclistbox.tcl
/usr/local/vtcl-%{version}/lib/lib_tcombobox.tcl
/usr/local/vtcl-%{version}/lib/lib_tix.tcl
/usr/local/vtcl-%{version}/lib/menu.tcl
/usr/local/vtcl-%{version}/lib/misc.tcl
/usr/local/vtcl-%{version}/lib/name.tcl
/usr/local/vtcl-%{version}/lib/prefs.tcl
/usr/local/vtcl-%{version}/lib/proc.tcl
/usr/local/vtcl-%{version}/lib/propmgr.tcl
/usr/local/vtcl-%{version}/lib/remove.sh
/usr/local/vtcl-%{version}/lib/tabpanel.tcl
/usr/local/vtcl-%{version}/lib/tclet.tcl
/usr/local/vtcl-%{version}/lib/toolbar.tcl
/usr/local/vtcl-%{version}/lib/tops.tcl
/usr/local/vtcl-%{version}/lib/tree.tcl
/usr/local/vtcl-%{version}/lib/var.tcl
/usr/local/vtcl-%{version}/lib/vtclib.tcl
/usr/local/vtcl-%{version}/lib/widget.tcl
/usr/local/vtcl-%{version}/sample/User_Compound.tcl
/usr/local/vtcl-%{version}/sample/hierarchy.tcl
/usr/local/vtcl-%{version}/sample/notebook.tcl
/usr/local/vtcl-%{version}/sample/panedwindow.tcl
/usr/local/vtcl-%{version}/sample/sampleBLT.tcl
/usr/local/vtcl-%{version}/ChangeLog
/usr/local/vtcl-%{version}/LICENSE
/usr/local/vtcl-%{version}/README
/usr/local/vtcl-%{version}/vtcl
/usr/local/vtcl-%{version}/vtclmac

%clean
rm -rf $RPM_BUILD_ROOT
