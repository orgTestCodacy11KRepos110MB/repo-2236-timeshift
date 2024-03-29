/*
 * DonationWindow.vala
 *
 * Copyright 2012-18 Tony George <teejeetech@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

using Gtk;

using TeeJee.Logging;
using TeeJee.FileSystem;
using TeeJee.JsonHelper;
using TeeJee.ProcessHelper;
using TeeJee.System;
using TeeJee.Misc;
using TeeJee.GtkHelper;

public class DonationWindow : Gtk.Window {

	private Gtk.Box vbox_main;
	private string username = "";
	private string appname = "Timeshift";

	public DonationWindow(Gtk.Window window) {

		set_title(_("Donate"));
		
		set_transient_for(window);
		set_destroy_with_parent(true);
		
		window_position = WindowPosition.CENTER_ON_PARENT;

		set_modal(true);
		set_resizable(false);
		set_deletable(true);

		// vbox_main
		vbox_main = new Gtk.Box(Orientation.VERTICAL, 12);
		vbox_main.margin = 12;

		this.add(vbox_main);
		
		if (get_user_id_effective() == 0){
			username = get_username();
		}
		
		string msg = "";
		
		// -----------------------------
		
		add_label("<b>%s</b>".printf(_("Donate")));
		
		msg = _("If you find this software useful, you can buy me a coffee by making a donation with PayPal.");

		add_label(msg);
		
		var hbox = add_hbox();
		
		add_button(hbox, _("Donate"),
			"https://www.paypal.com/cgi-bin/webscr?business=teejeetech@gmail.com&cmd=_xclick&currency_code=USD&item_name=%s+Donation".printf(appname));

		// -----------------------------
		
		add_label("<b>%s</b>".printf(_("Linux Mint Version")));
		
		msg = _("There is a fork of Timeshift maintained by Linux Mint which is under more active development. It is recommended to switch to the Linux Mint version.\n\nThis version of Timeshift will continue to be available but will only see minor fixes and changes. Any new features, issues, or pull requests should be submitted to the Linux Mint repository.");
		
		add_label(msg);
		
		hbox = add_hbox();
		
		add_button(hbox, _("Linux Mint GitHub"), "https://github.com/linuxmint/%s/issues".printf(appname));

		// close window ---------------------------------------------------------
		
		add_label("<b>%s</b>".printf(_("Website")));
		
		add_label("Visit teejeetech.com for more Linux apps.");
		
		add_label("");
		
		hbox = add_hbox();
		
		add_button(hbox, _("Website"), "https://teejeetech.com/");

		add_button(hbox, _("Store"), "https://teejeetech.com/shop/");
		
		var button = new Gtk.Button.with_label(_("Close"));
		hbox.add(button);
		
		button.clicked.connect(() => {
			this.destroy();
		});

		this.show_all();
	}

	private Gtk.Label add_label(string msg){

		var label = new Gtk.Label(msg);
		
		label.set_use_markup(true);
		
		label.wrap = true;
		label.wrap_mode = Pango.WrapMode.WORD;
		label.max_width_chars = 50;
		
		label.xalign = 0.0f;

		vbox_main.add(label);
		
		return label;
	}

	private Gtk.ButtonBox add_hbox(){

		var hbox = new Gtk.ButtonBox(Orientation.HORIZONTAL);
		hbox.set_layout(Gtk.ButtonBoxStyle.CENTER);
		hbox.set_spacing(6);
		vbox_main.add(hbox);
		return hbox;
	}
	
	private void add_button(Gtk.Box box, string text, string url){

		var button = new Gtk.Button.with_label(text);
		button.set_tooltip_text(url);
		box.add(button);

		//button.set_size_request(200,-1);
		
		button.clicked.connect(() => {
			xdg_open(url, username);
		});
	}
}

