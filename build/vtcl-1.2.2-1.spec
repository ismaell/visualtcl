Summary:	Visual Tcl is an integrated development environment for Tcl/Tk 8.0 and later.
Name:		vtcl
Version:	1.2.2
Release:	1
Icon:		title.gif
Copyright:	GPL
Group:	Applications
Source:	vtcl-1.2.2.tar.gz
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
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/doc
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/images
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit
mkdir -p $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample
install -m 644 usr/local/vtcl-1.2.2/demo/combo.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/combo.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/README				$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/README
install -m 644 usr/local/vtcl-1.2.2/demo/images/free.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/images/free.gif
install -m 644 usr/local/vtcl-1.2.2/demo/images/line.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/images/line.gif
install -m 644 usr/local/vtcl-1.2.2/demo/images/oval.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/images/oval.gif
install -m 644 usr/local/vtcl-1.2.2/demo/images/rect.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/images/rect.gif
install -m 644 usr/local/vtcl-1.2.2/demo/draw.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/draw.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/ex1_cmpd.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/ex1_cmpd.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/grid.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/grid.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/simple.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/simple.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/tclet-combo.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/tclet-combo.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/tclet-draw.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/tclet-draw.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/tclet-grid.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/tclet-grid.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/tclet-simple.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/tclet-simple.tcl
install -m 644 usr/local/vtcl-1.2.2/demo/tclets.html			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/demo/tclets.html
install -m 644 usr/local/vtcl-1.2.2/doc/tutorial.txt			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/doc/tutorial.txt
install -m 644 usr/local/vtcl-1.2.2/images/edit/copy.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/copy.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/cut.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/cut.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/icons.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/icons.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/new.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/new.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/open.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/open.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/paste.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/paste.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/replace.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/replace.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/save.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/save.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/search.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/search.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/srchbak.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/srchbak.gif
install -m 644 usr/local/vtcl-1.2.2/images/edit/srchfwd.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/edit/srchfwd.gif
install -m 644 usr/local/vtcl-1.2.2/images/anchor.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor.gif
install -m 644 usr/local/vtcl-1.2.2/images/anchor_c.ppm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_c.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_e.ppm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_e.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_n.ppm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_n.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_ne.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_ne.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_nw.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_nw.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_s.ppm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_s.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_se.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_se.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_sw.ppm		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_sw.ppm
install -m 644 usr/local/vtcl-1.2.2/images/anchor_w.ppm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/anchor_w.ppm
install -m 644 usr/local/vtcl-1.2.2/images/bg.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/bg.gif
install -m 644 usr/local/vtcl-1.2.2/images/border.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/border.gif
install -m 644 usr/local/vtcl-1.2.2/images/curse.xbm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/curse.xbm
install -m 644 usr/local/vtcl-1.2.2/images/down.xbm			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/down.xbm
install -m 644 usr/local/vtcl-1.2.2/images/ellipses.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/ellipses.gif
install -m 644 usr/local/vtcl-1.2.2/images/fg.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/fg.gif
install -m 644 usr/local/vtcl-1.2.2/images/fontbase.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/fontbase.gif
install -m 644 usr/local/vtcl-1.2.2/images/fontsize.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/fontsize.gif
install -m 644 usr/local/vtcl-1.2.2/images/fontstyle.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/fontstyle.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_button.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_button.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_buttonbox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_buttonbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_calendar.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_calendar.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_canvas.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_canvas.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_checkbox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_checkbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_checkbutton.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_checkbutton.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_combobox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_combobox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_dateentry.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_dateentry.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_entry.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_entry.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_entryfield.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_entryfield.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_feedback.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_feedback.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_frame.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_frame.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_graph.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_graph.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_hierarchy.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_hierarchy.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_hierbox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_hierbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_label.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_label.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_listbox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_listbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_mclistbox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_mclistbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_menu.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_menu.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_menubutton.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_menubutton.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_message.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_message.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_optionmenu.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_optionmenu.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_radiobox.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_radiobox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_radiobutton.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_radiobutton.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scale_h.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scale_h.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scale_v.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scale_v.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scrollbar_h.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scrollbar_h.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scrollbar_v.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scrollbar_v.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scrolledhtml.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scrolledhtml.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scrolledlistbox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scrolledlistbox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_scrolledtext.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_scrolledtext.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_spinint.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_spinint.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_stripchart.gif 		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_stripchart.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_text.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_text.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixComboBox.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixComboBox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixFileEntry.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixFileEntry.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixLabelEntry.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixLabelEntry.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixLabelFrame.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixLabelFrame.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixMeter.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixMeter.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixNoteBook.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixNoteBook.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixOptionMenu.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixOptionMenu.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixPanedWindow.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixPanedWindow.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixScrolledHList.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixScrolledHList.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixScrolledListBox.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixScrolledListBox.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixSelect.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixSelect.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tixTree.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tixTree.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_tix_unknown.gif 	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_tix_unknown.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_toolbar.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_toolbar.gif
install -m 644 usr/local/vtcl-1.2.2/images/icon_toplevel.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/icon_toplevel.gif
install -m 644 usr/local/vtcl-1.2.2/images/justify.gif			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/justify.gif
install -m 644 usr/local/vtcl-1.2.2/images/mgr_grid.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/mgr_grid.gif
install -m 644 usr/local/vtcl-1.2.2/images/mgr_pack.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/mgr_pack.gif
install -m 644 usr/local/vtcl-1.2.2/images/mgr_place.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/mgr_place.gif
install -m 644 usr/local/vtcl-1.2.2/images/mini-vtcl.xpm	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/mini-vtcl.xpm
install -m 644 usr/local/vtcl-1.2.2/images/ofg.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/ofg.gif
install -m 644 usr/local/vtcl-1.2.2/images/rel_groove.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/rel_groove.gif
install -m 644 usr/local/vtcl-1.2.2/images/rel_raised.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/rel_raised.gif
install -m 644 usr/local/vtcl-1.2.2/images/rel_ridge.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/rel_ridge.gif
install -m 644 usr/local/vtcl-1.2.2/images/rel_sunken.gif	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/rel_sunken.gif
install -m 644 usr/local/vtcl-1.2.2/images/relief.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/relief.gif
install -m 644 usr/local/vtcl-1.2.2/images/title.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/title.gif
install -m 644 usr/local/vtcl-1.2.2/images/unknown.gif		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/images/unknown.gif
install -m 644 usr/local/vtcl-1.2.2/lib/Makefile		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/Makefile
install -m 644 usr/local/vtcl-1.2.2/lib/about.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/about.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/attrbar.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/attrbar.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/balloon.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/balloon.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/bind.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/bind.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/color.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/color.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/command.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/command.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/compound.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/compound.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/compounds.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/compounds.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/console.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/console.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/do.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/do.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/dragsize.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/dragsize.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/dump.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/dump.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/edit.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/edit.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/editor.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/editor.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/file.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/file.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/font.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/font.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/globals.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/globals.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/handle.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/handle.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/help.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/help.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/images.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/images.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/input.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/input.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/lib_blt.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/lib_blt.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/lib_core.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/lib_core.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/lib_itcl.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/lib_itcl.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/lib_mclistbox.tcl       $RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/lib_mclistbox.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/lib_tix.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/lib_tix.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/menu.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/menu.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/misc.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/misc.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/name.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/name.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/prefs.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/prefs.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/proc.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/proc.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/propmgr.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/propmgr.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/remove.sh		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/remove.sh
install -m 644 usr/local/vtcl-1.2.2/lib/tabpanel.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/tabpanel.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/tclet.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/tclet.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/toolbar.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/toolbar.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/tops.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/tops.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/tree.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/tree.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/var.tcl			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/var.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/vtclib.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/vtclib.tcl
install -m 644 usr/local/vtcl-1.2.2/lib/widget.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/lib/widget.tcl
install -m 644 usr/local/vtcl-1.2.2/sample/User_Compound.tcl	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample/User_Compound.tcl
install -m 644 usr/local/vtcl-1.2.2/sample/hierarchy.tcl	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample/hierarchy.tcl
install -m 644 usr/local/vtcl-1.2.2/sample/notebook.tcl		$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample/notebook.tcl
install -m 644 usr/local/vtcl-1.2.2/sample/panedwindow.tcl	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample/panedwindow.tcl
install -m 644 usr/local/vtcl-1.2.2/sample/sampleBLT.tcl	$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/sample/sampleBLT.tcl
install -m 644 usr/local/vtcl-1.2.2/ChangeLog			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/ChangeLog
install -m 644 usr/local/vtcl-1.2.2/LICENSE			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/LICENSE
install -m 644 usr/local/vtcl-1.2.2/README			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/README	
install -m 755 usr/local/vtcl-1.2.2/vt.tcl 			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/vt.tcl
install -m 755 usr/local/vtcl-1.2.2/vtcl 			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/vtcl
install -m 644 usr/local/vtcl-1.2.2/vtclmac			$RPM_BUILD_ROOT/usr/local/vtcl-1.2.2/vtclmac

%files
/usr/local/vtcl-1.2.2/vt.tcl
/usr/local/vtcl-1.2.2/demo/combo.tcl
/usr/local/vtcl-1.2.2/demo/README
/usr/local/vtcl-1.2.2/demo/images/free.gif
/usr/local/vtcl-1.2.2/demo/images/line.gif
/usr/local/vtcl-1.2.2/demo/images/oval.gif
/usr/local/vtcl-1.2.2/demo/images/rect.gif
/usr/local/vtcl-1.2.2/demo/draw.tcl
/usr/local/vtcl-1.2.2/demo/ex1_cmpd.tcl
/usr/local/vtcl-1.2.2/demo/grid.tcl
/usr/local/vtcl-1.2.2/demo/simple.tcl
/usr/local/vtcl-1.2.2/demo/tclet-combo.tcl
/usr/local/vtcl-1.2.2/demo/tclet-draw.tcl
/usr/local/vtcl-1.2.2/demo/tclet-grid.tcl
/usr/local/vtcl-1.2.2/demo/tclet-simple.tcl
/usr/local/vtcl-1.2.2/demo/tclets.html
/usr/local/vtcl-1.2.2/doc/tutorial.txt
/usr/local/vtcl-1.2.2/images/edit/copy.gif
/usr/local/vtcl-1.2.2/images/edit/cut.gif
/usr/local/vtcl-1.2.2/images/edit/icons.gif
/usr/local/vtcl-1.2.2/images/edit/new.gif
/usr/local/vtcl-1.2.2/images/edit/open.gif
/usr/local/vtcl-1.2.2/images/edit/paste.gif
/usr/local/vtcl-1.2.2/images/edit/replace.gif
/usr/local/vtcl-1.2.2/images/edit/save.gif
/usr/local/vtcl-1.2.2/images/edit/search.gif
/usr/local/vtcl-1.2.2/images/edit/srchbak.gif
/usr/local/vtcl-1.2.2/images/edit/srchfwd.gif
/usr/local/vtcl-1.2.2/images/anchor.gif
/usr/local/vtcl-1.2.2/images/anchor_c.ppm
/usr/local/vtcl-1.2.2/images/anchor_e.ppm
/usr/local/vtcl-1.2.2/images/anchor_n.ppm
/usr/local/vtcl-1.2.2/images/anchor_ne.ppm
/usr/local/vtcl-1.2.2/images/anchor_nw.ppm
/usr/local/vtcl-1.2.2/images/anchor_s.ppm
/usr/local/vtcl-1.2.2/images/anchor_se.ppm
/usr/local/vtcl-1.2.2/images/anchor_sw.ppm
/usr/local/vtcl-1.2.2/images/anchor_w.ppm
/usr/local/vtcl-1.2.2/images/bg.gif
/usr/local/vtcl-1.2.2/images/border.gif
/usr/local/vtcl-1.2.2/images/curse.xbm
/usr/local/vtcl-1.2.2/images/down.xbm
/usr/local/vtcl-1.2.2/images/ellipses.gif
/usr/local/vtcl-1.2.2/images/fg.gif
/usr/local/vtcl-1.2.2/images/fontbase.gif
/usr/local/vtcl-1.2.2/images/fontsize.gif
/usr/local/vtcl-1.2.2/images/fontstyle.gif
/usr/local/vtcl-1.2.2/images/icon_button.gif
/usr/local/vtcl-1.2.2/images/icon_buttonbox.gif
/usr/local/vtcl-1.2.2/images/icon_calendar.gif
/usr/local/vtcl-1.2.2/images/icon_canvas.gif
/usr/local/vtcl-1.2.2/images/icon_checkbox.gif
/usr/local/vtcl-1.2.2/images/icon_checkbutton.gif
/usr/local/vtcl-1.2.2/images/icon_combobox.gif
/usr/local/vtcl-1.2.2/images/icon_dateentry.gif
/usr/local/vtcl-1.2.2/images/icon_entry.gif
/usr/local/vtcl-1.2.2/images/icon_entryfield.gif
/usr/local/vtcl-1.2.2/images/icon_feedback.gif
/usr/local/vtcl-1.2.2/images/icon_frame.gif
/usr/local/vtcl-1.2.2/images/icon_graph.gif
/usr/local/vtcl-1.2.2/images/icon_hierarchy.gif
/usr/local/vtcl-1.2.2/images/icon_hierbox.gif
/usr/local/vtcl-1.2.2/images/icon_label.gif
/usr/local/vtcl-1.2.2/images/icon_listbox.gif
/usr/local/vtcl-1.2.2/images/icon_mclistbox.gif
/usr/local/vtcl-1.2.2/images/icon_menu.gif
/usr/local/vtcl-1.2.2/images/icon_menubutton.gif
/usr/local/vtcl-1.2.2/images/icon_message.gif
/usr/local/vtcl-1.2.2/images/icon_optionmenu.gif
/usr/local/vtcl-1.2.2/images/icon_radiobox.gif
/usr/local/vtcl-1.2.2/images/icon_radiobutton.gif
/usr/local/vtcl-1.2.2/images/icon_scale_h.gif
/usr/local/vtcl-1.2.2/images/icon_scale_v.gif
/usr/local/vtcl-1.2.2/images/icon_scrollbar_h.gif
/usr/local/vtcl-1.2.2/images/icon_scrollbar_v.gif
/usr/local/vtcl-1.2.2/images/icon_scrolledhtml.gif
/usr/local/vtcl-1.2.2/images/icon_scrolledlistbox.gif
/usr/local/vtcl-1.2.2/images/icon_scrolledtext.gif
/usr/local/vtcl-1.2.2/images/icon_spinint.gif
/usr/local/vtcl-1.2.2/images/icon_stripchart.gif
/usr/local/vtcl-1.2.2/images/icon_text.gif
/usr/local/vtcl-1.2.2/images/icon_tixComboBox.gif
/usr/local/vtcl-1.2.2/images/icon_tixFileEntry.gif
/usr/local/vtcl-1.2.2/images/icon_tixLabelEntry.gif
/usr/local/vtcl-1.2.2/images/icon_tixLabelFrame.gif
/usr/local/vtcl-1.2.2/images/icon_tixMeter.gif
/usr/local/vtcl-1.2.2/images/icon_tixNoteBook.gif
/usr/local/vtcl-1.2.2/images/icon_tixOptionMenu.gif
/usr/local/vtcl-1.2.2/images/icon_tixPanedWindow.gif
/usr/local/vtcl-1.2.2/images/icon_tixScrolledHList.gif
/usr/local/vtcl-1.2.2/images/icon_tixScrolledListBox.gif
/usr/local/vtcl-1.2.2/images/icon_tixSelect.gif
/usr/local/vtcl-1.2.2/images/icon_tixTree.gif
/usr/local/vtcl-1.2.2/images/icon_tix_unknown.gif
/usr/local/vtcl-1.2.2/images/icon_toolbar.gif
/usr/local/vtcl-1.2.2/images/icon_toplevel.gif
/usr/local/vtcl-1.2.2/images/justify.gif
/usr/local/vtcl-1.2.2/images/mgr_grid.gif
/usr/local/vtcl-1.2.2/images/mgr_pack.gif
/usr/local/vtcl-1.2.2/images/mgr_place.gif
/usr/local/vtcl-1.2.2/images/mini-vtcl.xpm
/usr/local/vtcl-1.2.2/images/ofg.gif
/usr/local/vtcl-1.2.2/images/rel_groove.gif
/usr/local/vtcl-1.2.2/images/rel_raised.gif
/usr/local/vtcl-1.2.2/images/rel_ridge.gif
/usr/local/vtcl-1.2.2/images/rel_sunken.gif
/usr/local/vtcl-1.2.2/images/relief.gif
/usr/local/vtcl-1.2.2/images/title.gif
/usr/local/vtcl-1.2.2/images/unknown.gif
/usr/local/vtcl-1.2.2/lib/Makefile
/usr/local/vtcl-1.2.2/lib/about.tcl
/usr/local/vtcl-1.2.2/lib/attrbar.tcl
/usr/local/vtcl-1.2.2/lib/balloon.tcl
/usr/local/vtcl-1.2.2/lib/bind.tcl
/usr/local/vtcl-1.2.2/lib/color.tcl
/usr/local/vtcl-1.2.2/lib/command.tcl
/usr/local/vtcl-1.2.2/lib/compound.tcl
/usr/local/vtcl-1.2.2/lib/compounds.tcl
/usr/local/vtcl-1.2.2/lib/console.tcl
/usr/local/vtcl-1.2.2/lib/do.tcl
/usr/local/vtcl-1.2.2/lib/dragsize.tcl
/usr/local/vtcl-1.2.2/lib/dump.tcl
/usr/local/vtcl-1.2.2/lib/edit.tcl
/usr/local/vtcl-1.2.2/lib/editor.tcl
/usr/local/vtcl-1.2.2/lib/file.tcl
/usr/local/vtcl-1.2.2/lib/font.tcl
/usr/local/vtcl-1.2.2/lib/globals.tcl
/usr/local/vtcl-1.2.2/lib/handle.tcl
/usr/local/vtcl-1.2.2/lib/help.tcl
/usr/local/vtcl-1.2.2/lib/images.tcl
/usr/local/vtcl-1.2.2/lib/input.tcl
/usr/local/vtcl-1.2.2/lib/lib_blt.tcl
/usr/local/vtcl-1.2.2/lib/lib_core.tcl
/usr/local/vtcl-1.2.2/lib/lib_itcl.tcl
/usr/local/vtcl-1.2.2/lib/lib_mclistbox.tcl
/usr/local/vtcl-1.2.2/lib/lib_tix.tcl
/usr/local/vtcl-1.2.2/lib/menu.tcl
/usr/local/vtcl-1.2.2/lib/misc.tcl
/usr/local/vtcl-1.2.2/lib/name.tcl
/usr/local/vtcl-1.2.2/lib/prefs.tcl
/usr/local/vtcl-1.2.2/lib/proc.tcl
/usr/local/vtcl-1.2.2/lib/propmgr.tcl
/usr/local/vtcl-1.2.2/lib/remove.sh
/usr/local/vtcl-1.2.2/lib/tabpanel.tcl
/usr/local/vtcl-1.2.2/lib/tclet.tcl
/usr/local/vtcl-1.2.2/lib/toolbar.tcl
/usr/local/vtcl-1.2.2/lib/tops.tcl
/usr/local/vtcl-1.2.2/lib/tree.tcl
/usr/local/vtcl-1.2.2/lib/var.tcl
/usr/local/vtcl-1.2.2/lib/vtclib.tcl
/usr/local/vtcl-1.2.2/lib/widget.tcl
/usr/local/vtcl-1.2.2/sample/User_Compound.tcl
/usr/local/vtcl-1.2.2/sample/hierarchy.tcl
/usr/local/vtcl-1.2.2/sample/notebook.tcl
/usr/local/vtcl-1.2.2/sample/panedwindow.tcl
/usr/local/vtcl-1.2.2/sample/sampleBLT.tcl
/usr/local/vtcl-1.2.2/ChangeLog
/usr/local/vtcl-1.2.2/LICENSE
/usr/local/vtcl-1.2.2/README
/usr/local/vtcl-1.2.2/vtcl
/usr/local/vtcl-1.2.2/vtclmac

%clean
rm -rf $RPM_BUILD_ROOT
