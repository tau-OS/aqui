public class Aqui.MainWindow : He.ApplicationWindow {
    private Aqui.GeoClue geo_clue;
    private Aqui.LocationMarker point;
    private Gtk.Spinner spinner;
    private Shumate.SimpleMap smap;
    private Shumate.MarkerLayer poi_layer;
    private Gtk.ListStore location_store;
    private GLib.Cancellable search_cancellable;

    public MainWindow (He.Application app) {
        Object (
            application: app,
            title: "Aqui"
        );
    }

    construct {
        geo_clue = new Aqui.GeoClue ();
        location_store = new Gtk.ListStore (2, typeof (Geocode.Place), typeof (string));

        var location_completion = new Gtk.EntryCompletion () {
            minimum_key_length = 3,
            model = location_store,
            text_column = 1
        };

        location_completion.set_match_func ((completion, key, iter) => {
            return true;
        });
        location_completion.match_selected.connect ((model, iter) => suggestion_selected (model, iter));

        try {
            var renderer = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/{z}/{x}/{y}.png") {
                name = "OpenStreetMap",
                id = "osm-print",
                license = "© OpenStreetMap",
                license_uri = "http://www.openstreetmap.org/copyright",
                min_zoom_level = 2,
                max_zoom_level = 19,
                tile_size = 256
            };
            var registry = new Shumate.MapSourceRegistry.with_defaults ();
            registry.add (renderer);

            smap = new Shumate.SimpleMap () {
                map_source = renderer,
                show_zoom_buttons = false
            };

            poi_layer = new Shumate.MarkerLayer.full (smap.get_map ().get_viewport (), Gtk.SelectionMode.SINGLE);
            smap.get_map ().add_layer (poi_layer);

            spinner = new Gtk.Spinner () {
                visible = false,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END,
            };
    
            var search_entry = new Gtk.Entry () {
                placeholder_text = _("Search Location"),
                tooltip_text = _("Search Location"),
                primary_icon_name = "system-search-symbolic",
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START
            };
            search_entry.add_css_class ("search-entry");
            search_entry.set_completion (location_completion);
    
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            var headerbar_blur = new He.AppBar () {
                show_back = false,
                show_buttons = false,
                viewtitle_widget = box
            };
            headerbar_blur.add_css_class ("hb-blur");
    
            var headerbar = new He.AppBar () {
                show_back = false,
                show_buttons = true
            };
            headerbar.viewtitle_widget = (search_entry);
            headerbar.append (spinner);
            headerbar.add_css_class ("hb");
    
            var headerbar_overlay = new Gtk.Overlay () {
                valign = Gtk.Align.START,
            };
            headerbar_overlay.add_overlay (headerbar);
            headerbar_overlay.set_child (headerbar_blur);
    
            var main_box = new Gtk.Overlay ();
            main_box.add_overlay (headerbar_overlay);
            main_box.set_child (smap);
    
            var overlay_button = new He.OverlayButton ("mark-location-symbolic", null, null);
            overlay_button.child = main_box;
    
            this.set_child (overlay_button);

            set_size_request (360, 360);
            default_height = 513;
            default_width = 887;

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

    private void show_current_location () {
        Spinner.activate (spinner, _("Detecting your current location…"));

        geo_clue.get_current_location.begin ((obj, res) => {
            var location = geo_clue.get_current_location.end (res);
            smap.get_map ().center_on (location.latitude, location.longitude);
            smap.get_map ().go_to_full (location.latitude, location.longitude, 19);
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
            if (places != null) {
                location_store.clear ();
            }

            Gtk.TreeIter location;
            foreach (unowned var place in places) {
                location_store.append (out location);
                location_store.set (location, 0, place, 1, place.name);
            }
        } catch (Error error) {
            warning (error.message);
        }
    }

    private bool suggestion_selected (Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value place;

        model.get_value (iter, 0, out place);
        center_map ((Geocode.Place)place);

        return false;
    }

    private void center_map (Geocode.Place loc) {
        if (point == null) {
            point = new Aqui.LocationMarker ();
        }

        point.latitude = loc.location.latitude;
        point.longitude = loc.location.longitude;

        smap.get_map ().go_to_full (point.latitude, point.longitude, 14);

        poi_layer.remove_all ();
        poi_layer.add_marker (point);
    }
}
