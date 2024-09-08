public class LocationResult : He.Bin {
    public Geocode.Place place { get; construct; }

    public LocationResult (Geocode.Place place) {
        Object (
            place: place
        );
    }

    construct {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);

        var icon = new Gtk.Image.from_icon_name ("location-active-symbolic") {
            pixel_size = 24
        };

        var place_name = new Gtk.Label (place.name) {
            xalign = 0,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR
        };
        place_name.add_css_class ("cb-title");

        var place_location = new Gtk.Label (place.country ?? "") {
            xalign = 0,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD_CHAR
        };
        place_location.add_css_class ("cb-subtitle");

        var info_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        info_box.append (place_name);
        info_box.append (place_location);

        box.append (icon);
        box.append (info_box);
        box.hexpand = true;
        box.add_css_class ("mini-content-block");

        child = box;
    }
}