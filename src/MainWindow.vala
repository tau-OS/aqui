public class Aqui.MainWindow : He.ApplicationWindow {
    private Aqui.GeoClue geo_clue;
    private Aqui.LocationMarker point;
    private GLib.Cancellable search_cancellable;
    private Gtk.Box bubble;
    private Gtk.Entry search_entry;
    private Gtk.ListBox search_results;
    private Gtk.Popover search_popover;
    private Gtk.Spinner spinner;
    private He.AppBar headerbar;
    private He.Desktop desktop = new He.Desktop ();
    private Shumate.MarkerLayer poi_layer;

    private bool result_just_selected = false;
    private uint search_timeout_id = 0;

    public Aqui.Favorites favorites;
    public He.Application app {get; construct;}
    public Shumate.SimpleMap smap;

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_ABOUT = "about";
    public SimpleActionGroup actions;
    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        {ACTION_ABOUT, action_about },
    };

    public MainWindow (He.Application app) {
        Object (
            app: app,
            application: app,
            title: "Aqui"
        );

        actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("win", actions);
    }

    construct {
        geo_clue = new Aqui.GeoClue ();

        try {
            var renderer = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/{z}/{x}/{y}.png") {
                name = "OpenStreetMap",
                id = "osm-print",
                license = "© OpenStreetMap",
                license_uri = "http://www.openstreetmap.org/copyright",
                min_zoom_level = 2,
                max_zoom_level = 20,
                tile_size = 256
            };
            var registry = new Shumate.MapSourceRegistry.with_defaults ();
            registry.add (renderer);

            smap = new Shumate.SimpleMap () {
                map_source = renderer,
                show_zoom_buttons = false,
                vexpand = true
            };

            poi_layer = new Shumate.MarkerLayer.full (smap.get_map ().get_viewport (), Gtk.SelectionMode.SINGLE);
            smap.get_map ().add_layer (poi_layer);

            if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
                smap.get_map ().add_css_class ("night");
            } else {
                smap.get_map ().remove_css_class ("night");
            }

            desktop.notify["prefers-color-scheme"].connect (() => {
                if (desktop.prefers_color_scheme == He.Desktop.ColorScheme.DARK) {
                    smap.get_map ().add_css_class ("night");
                } else {
                    smap.get_map ().remove_css_class ("night");
                }
            });

            spinner = new Gtk.Spinner () {
                visible = false,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END,
            };

            search_entry = new Gtk.Entry () {
                placeholder_text = _("Search Locations…"),
                tooltip_text = _("Search Locations…"),
                primary_icon_name = "system-search-symbolic",
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START
            };
            search_entry.add_css_class ("text-field");
            search_entry.add_css_class ("search-entry");

            search_results = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.SINGLE,
                visible = false
            };
            search_results.add_css_class ("content-listbox");

            var search_results_scrolled = new Gtk.ScrolledWindow () {
                child = search_results,
                margin_top = margin_bottom = margin_start = margin_end = 8,
                height_request = 300,
                width_request = 300
            };

            search_popover = new Gtk.Popover () {
                child = search_results_scrolled,
                has_arrow = false,
                autohide = false,
                position = Gtk.PositionType.BOTTOM
            };

            search_entry.changed.connect (() => {
                if (result_just_selected) {
                    result_just_selected = false;
                    return;
                }

                if (search_timeout_id != 0) {
                    GLib.Source.remove (search_timeout_id);
                }

                if (search_entry.text == "") {
                    search_popover.popdown ();
                    return;
                }

                search_timeout_id = GLib.Timeout.add (300, () => {
                    Spinner.activate (spinner, _("Searching locations…"));
                    compute_location.begin (search_entry.text, (obj, res) => {
                        Spinner.deactivate (spinner);
                    });
                    search_timeout_id = 0;
                    return GLib.Source.REMOVE;
                });
            });

            var focus_controller = new Gtk.EventControllerFocus ();
            focus_controller.enter.connect (() => {
                if (!result_just_selected && search_results.get_first_child () != null) {
                    search_popover.popup ();
                }
            });
            search_entry.add_controller (focus_controller);

            search_results.row_activated.connect (on_search_result_selected);
            search_popover.set_parent (search_entry);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var menu_popover = new Gtk.Popover () {
                autohide = true,
                has_arrow = false
            };
            var about_menu_item = create_button_menu_item (
                _("About Aqui…"),
                "win.about"
            );
            about_menu_item.clicked.connect (() => {
                menu_popover.popdown ();
            });
            var menu_popover_grid = new Gtk.Grid () {
                orientation = Gtk.Orientation.VERTICAL
            };
            menu_popover_grid.attach (about_menu_item, 0, 0, 1, 1);
            menu_popover.has_arrow = false;
            menu_popover.child = menu_popover_grid;

            var menu_button = new Gtk.MenuButton () {
                popover = menu_popover,
                icon_name = "open-menu-symbolic"
            };

            //  favorites = new Aqui.Favorites (this) {
            //      autohide = true
            //  };
            //  favorites.list.row_selected.connect ((row) => {
            //      select_location.begin (((FavoriteRow)row).item.place, (obj, res) => {
            //          Spinner.deactivate (spinner);
            //      });
            //  });

            //  var main_fav_button = new Gtk.MenuButton () {
            //      popover = favorites,
            //      icon_name = "emblem-favorite-symbolic"
            //  };

            headerbar = new He.AppBar () {
                show_back = false,
                show_right_title_buttons = true,
                valign = Gtk.Align.START
            };
            headerbar.viewtitle_widget = (search_entry);
            headerbar.append (spinner);
            // TODO: Favourite popup remove favourites.
            // headerbar.append (main_fav_button);
            headerbar.append_menu (menu_button);
            headerbar.add_css_class ("hb");

            var main_box = new Gtk.Overlay ();
            main_box.add_overlay (headerbar);
            main_box.set_child (smap);

            var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            content_box.append (main_box);

            bubble = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
                visible = false,
                vexpand = true,
                hexpand_set = true
            };
            var bubble_overlay = new Bis.Lapel () {
                fold_policy = Bis.LapelFoldPolicy.NEVER
            };
            bubble_overlay.lapel = (bubble);
            bubble_overlay.add_css_class ("bubble");
            bubble_overlay.set_content (content_box);

            var overlay_button = new He.OverlayButton ("mark-location-symbolic", null, null) {
                typeb = PRIMARY
            };
            overlay_button.child = bubble_overlay;

            this.set_child (overlay_button);

            set_size_request (360, 294);
            default_height = 600;
            default_width = 800;

            overlay_button.clicked.connect (() => {
                show_current_location ();
            });

            search_entry.changed.connect (() => {
                if (search_entry.text == "") {
                    return;
                }

                Spinner.activate (spinner, _("Searching locations…"));

                compute_location.begin (search_entry.text, (obj, res) => {
                    Spinner.deactivate (spinner);
                });

                Timeout.add (5000, () => {
                    Spinner.deactivate (spinner);

                    return false;
                });
            });

            var event_controller_key = new Gtk.EventControllerKey ();
            event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
                if (Gdk.ModifierType.CONTROL_MASK in state) {
                    switch (keyval) {
                        case Gdk.Key.w:
                            destroy ();
                            return true;
                        case Gdk.Key.f:
                            search_entry.grab_focus ();
                            return true;
                        default:
                            break;
                    }
                }

                return false;
            });
            ((Gtk.Widget)this).add_controller (event_controller_key);
        } catch (Error e) {

        }
    }

    public void action_about () {
        // TRANSLATORS: 'Name <email@domain.com>' or 'Name https://website.example'
        string translators = (_(""));

        var about = new He.AboutWindow (
            this,
            "Aqui",
            "com.fyralabs.Aqui",
            "0.1.0",
            "com.fyralabs.Aqui",
            "https://github.com/tau-OS/aqui/tree/main/po",
            "https://github.com/tau-OS/aqui/issues/new",
            "https://github.com/tau-OS/aqui",
            {translators},
            {"Fyra Labs"},
            2023, // Year of first publication.
            He.AboutWindow.Licenses.GPLV3,
            He.Colors.GREEN
        );
        about.present ();
    }

    private Gtk.Button create_button_menu_item (string label, string? action_name) {
        var labelb = new Gtk.Label (label) {
            xalign = 0,
            halign = Gtk.Align.START,
            hexpand = true
        };
        var button = new Gtk.Button () {
            child = labelb,
            hexpand = true
        };
        button.set_action_name (action_name);
        button.add_css_class ("flat");
        button.add_css_class ("menu-button");
        return button;
    }

    private void show_current_location () {
        Spinner.activate (spinner, _("Detecting your current location…"));

        geo_clue.get_current_location.begin ((obj, res) => {
            var location = geo_clue.get_current_location.end (res);
            smap.get_map ().center_on (location.latitude, location.longitude);
            smap.get_map ().go_to_full (location.latitude, location.longitude, 16);
            Spinner.deactivate (spinner);
        });

        Timeout.add (5000, () => {
            Spinner.deactivate (spinner);
            return false;
        });
    }

    private async void compute_location (string loc) {
        if (search_cancellable != null) {
            search_cancellable.cancel ();
        }

        search_cancellable = new GLib.Cancellable ();

        var forward = new Geocode.Forward.for_string (loc) {
            answer_count = 10
        };
        try {
            var places = yield forward.search_async (search_cancellable);

            // Remove existing children
            while (search_results.get_first_child () != null) {
                search_results.remove (search_results.get_first_child ());
            }

            if (places != null && places.length () > 0) {
                foreach (unowned var place in places) {
                    var result_widget = new LocationResult (place);
                    search_results.append (result_widget);
                }
                search_results.visible = true;
                search_popover.popup ();
            } else {
                search_results.visible = false;
                search_popover.popdown ();
            }
        } catch (Error error) {
            warning ("Error searching for location: %s", error.message);
        }
    }

    private void on_search_result_selected (Gtk.ListBoxRow row) {
        if (row == null) {
            warning("Selected row is null");
            return;
        }

        var result_widget = row.get_child() as LocationResult;
        if (result_widget == null) {
            warning("Selected row does not contain a LocationResult");
            return;
        }

        var place = result_widget.place;
        if (place == null) {
            warning("LocationResult does not contain a valid place");
            return;
        }

        result_just_selected = true;
        center_map(place);
        search_popover.popdown();
        search_entry.text = place.name ?? "";

        GLib.Timeout.add(400, () => {
            search_entry.text = "";
            result_just_selected = false;
            return GLib.Source.REMOVE;
        });
    }

    private void center_map (Geocode.Place loc) {
        if (loc == null || loc.location == null) {
            warning("Invalid place or location");
            return;
        }

        if (point == null) {
            point = new Aqui.LocationMarker ();
        }

        point.latitude = loc.location.latitude;
        point.longitude = loc.location.longitude;

        smap.get_map ().go_to_full (point.latitude, point.longitude, 10);

        Aqui.Application.settings.set ("last-viewed-location", "(dd)", point.latitude, point.longitude);

        poi_layer.remove_all ();
        poi_layer.add_marker (point);

        search_popover.popdown ();

        double x, y;
        //Gtk.Allocation map_size;
        smap.get_map ().get_viewport ().location_to_widget_coords (this, point.latitude, point.longitude, out x, out y);
        //smap.get_map ().get_allocation(out map_size);

        var child = new Aqui.Wikipedia ();
        var we = do_wikipedia_lookup (loc.location.get_description ().split(", ")[0]);
        child.set_wikipedia_entry (we);

        if (bubble.get_first_child() != null) bubble.remove (bubble.get_first_child ());

        bubble.append (child);
        bubble.visible = true;
        child.close_button.clicked.connect (() => {
            bubble.visible = false;
            search_entry.text = "";
            point.unparent ();
        });

        //  var n = favorites.fav_store.get_n_items ();
        //  for (int i = 0; i < n; i++) {
        //      var item = (FavoriteItem) favorites.fav_store.get_object (i);
        //      if (item.place == loc.location.get_description ().split(", ")[0]) {
        //          child.fav_button.active = bubble.visible ? true : false;
        //          ((He.ButtonContent)child.fav_button.get_first_child ()).label = (_("Unfavorite"));
        //      }
        //  }

        //  child.fav_button.toggled.connect (() => {
        //      if (child.fav_button.active) {
        //          var item = new FavoriteItem (loc.location.get_description ().split(", ")[0]);
        //          favorites.fav_store.add (item);
        //          favorites.save ();
        //          ((He.ButtonContent)child.fav_button.get_first_child ()).label = (_("Unfavorite"));
        //      } else {
        //          var nn = favorites.fav_store.get_n_items ();
        //          for (int i = 0; i < nn; i++) {
        //              var item = (FavoriteItem) favorites.fav_store.get_object (i);
        //              if (item.place == loc.location.get_description ().split(", ")[0]) {
        //                  ((He.ButtonContent)child.fav_button.get_first_child ()).label = (_("Favorite"));
        //                  favorites.fav_store.remove (item);
        //              }
        //          }
        //          favorites.save ();
        //      }
        //  });
    }

    public WikipediaEntry? do_wikipedia_lookup (string term) {
        var uri = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&imageinfo&exintro&explaintext&redirects=1&titles=%s".printf(term);
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", uri);
        var wikipedia_entry = new WikipediaEntry();

        try {
            GLib.Bytes byt = session.send_and_read (message, null);
            var parser = new Json.Parser();
            parser.load_from_data((string)byt.get_data(), -1);
            var root_object = parser.get_root().get_object();
            var pages = root_object.get_object_member("query").get_object_member("pages");
            var members = pages.get_members();

            foreach (var member in members) {
                var element = pages.get_object_member(member);
                wikipedia_entry.title = element.get_string_member("title");
                wikipedia_entry.extract = element.get_string_member("extract").split (". ")[0] +
                                            ". " + element.get_string_member("extract").split (". ")[1] +
                                            "."; // We are only interested in a small blurb.
                wikipedia_entry.pageid = element.get_int_member("pageid");
            }

            wikipedia_entry.url = "http://en.wikipedia.org/?curid=%ld".printf((long)wikipedia_entry.pageid);
        } catch (Error e) {
            warning(_("Unable to load Wikipedia article for: ") + term);
        }

        var imguri = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=pageimages&pithumbsize=250&pilimit=1&titles=%s".printf(term);
        var imgsession = new Soup.Session ();
        var imgmessage = new Soup.Message ("GET", imguri);

        try {
            GLib.Bytes imgbyt = imgsession.send_and_read (imgmessage, null);
            var imgparser = new Json.Parser();
            imgparser.load_from_data((string)imgbyt.get_data(), -1);
            var imgroot_object = imgparser.get_root().get_object();
            var imgpages = imgroot_object.get_object_member("query").get_object_member("pages");
            var imgmembers = imgpages.get_members();

            foreach (var imgmember in imgmembers) {
                var imgelement = imgpages.get_object_member(imgmember);
                var imgobj = imgelement.get_object_member("thumbnail");
                wikipedia_entry.pic = imgobj.get_string_member("source");
            }
        } catch (Error e) {
            warning(_("Unable to load Wikipedia article image for: ") + term);
        }

        return wikipedia_entry;
    }
}
