public class Aqui.MainWindow : He.ApplicationWindow {
    private Gtk.Spinner spinner;

    public MainWindow (He.Application app) {
        Object (
            application: app,
            title: "Aqui"
        );
    }

    construct {
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

            var map = new Shumate.SimpleMap () {
                map_source = renderer,
                show_zoom_buttons = false
            };

            spinner = new Gtk.Spinner () {
                visible = false,
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.END,
            };
    
            var search_entry = new Gtk.SearchEntry () {
                placeholder_text = _("Search Location"),
                tooltip_text = _("Search Location"),
                valign = Gtk.Align.CENTER,
                halign = Gtk.Align.START,
            };
            search_entry.add_css_class ("search-entry");
    
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
            main_box.set_child (map);
    
            var overlay_button = new He.OverlayButton ("mark-location-symbolic", null, null);
            overlay_button.child = main_box;
    
            this.set_child (overlay_button);

            set_size_request (360, 360);
            default_height = 513;
            default_width = 887;

            overlay_button.clicked.connect (() => {
                show_current_location ();
            });

            search_entry.search_changed.connect (() => {
                if (search_entry.text == "") {
                    return;
                }

                Spinner.activate (spinner, _("Searching locations…"));

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

        Timeout.add (5000, () => {
            Spinner.deactivate (spinner);
            return false;
        });
    }
}
