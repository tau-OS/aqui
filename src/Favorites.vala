public class Aqui.FavoriteRow : Gtk.ListBoxRow {
    public Geocode.Place place {get; construct;}

    public FavoriteRow (Geocode.Place place) {
        Object (place: place);
    }

    construct {
        var lname = place.location.description;

        var loc_label = new Gtk.Label (lname);
        loc_label.halign = Gtk.Align.START;
        loc_label.add_css_class ("cb-title");

        var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        main_box.add_css_class ("mini-content-block");
        main_box.append (loc_label);

        this.set_child (main_box);
    }
}

public class Aqui.Favorites : Gtk.Popover {
    public MainWindow win {get; construct;}

    private Shumate.SimpleMap map_view = null;

    public Gtk.ListBox list;

    private const int N_VISIBLE = 6;

    public Favorites (MainWindow win) {
        Object (win: win);
    }

    construct {
        this.map_view = win.smap;
        this.has_arrow = false;
        this.width_request = 320;

        var entry = new Gtk.Entry () {
            placeholder_text = _("Search Favorites…"),
            tooltip_text = _("Search Favorites…"),
            primary_icon_name = "system-search-symbolic",
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.START
        };
        entry.add_css_class ("search-entry");

        entry.changed.connect(() => list.invalidate_filter());

        var entry_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        entry_box.append (entry);

        list = new Gtk.ListBox ();
        list.add_css_class ("content-list");

        list.row_activated.connect((row) => {
            this.hide();
            map_view.get_map ().go_to_full (((FavoriteRow)row).place.location.latitude, ((FavoriteRow)row).place.location.longitude, 10);
        });
        list.set_filter_func((row) => {
            return ((FavoriteRow)row).place.location.description == (entry.text);
        });

        var sw = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            vexpand = true
        };
        sw.set_child (list);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        main_box.append (entry_box);
        main_box.append (sw);

        child = (main_box);
    }
}