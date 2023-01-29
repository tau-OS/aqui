public class Aqui.FavoriteItem : Object, Utils.ContentItem {
    public string place {get; construct;}

    public string? name {
        get {
            return place;
        }
        set {}
    }
    public FavoriteItem (string place) {
        Object (place: place);
    }

    public void serialize (GLib.VariantBuilder builder) {
        builder.open (new GLib.VariantType ("a{sv}"));
        builder.add ("{sv}", "place", new GLib.Variant.string (place));
        builder.close ();
    }

    public static FavoriteItem? deserialize (Variant variant) {
        string key;
        Variant val;
        string? place = null;

        var iter = variant.iterator ();
        while (iter.next ("{sv}", out key, out val)) {
            switch (key) {
                case "place":
                    place = (string)val;
                    break;
            }
        }

        return new FavoriteItem (place);
    }
}

public class Aqui.FavoriteRow : Gtk.ListBoxRow {
    public FavoriteItem item {get; construct set;}

    public FavoriteRow (FavoriteItem item) {
        Object (item: item);

        var loc_label = new Gtk.Label (item.place);
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
    public Gtk.ListBox list;
    public Utils.ContentStore fav_store = new Utils.ContentStore ();

    private Shumate.SimpleMap map_view = null;
    private const int N_VISIBLE = 6;

    public Favorites (MainWindow win) {
        Object (win: win);

        this.map_view = win.smap;
        this.has_arrow = false;
        this.width_request = 300;

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
        list.bind_model (fav_store, (item) => {
            var row = new FavoriteRow ((FavoriteItem) item);
            return row;
        });

        fav_store.items_changed.connect ((position, removed, added) => {
            save ();
        });
        load ();

        var sw = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            height_request = 380,
            hexpand = true,
            vexpand = true
        };
        sw.set_child (list);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);
        main_box.append (entry_box);
        main_box.append (sw);

        child = (main_box);
    }

    public void save () {
        Aqui.Application.settings.set_value ("favorites", fav_store.serialize ());
    }
    public void load () {
        fav_store.deserialize (Aqui.Application.settings.get_value ("favorites"), FavoriteItem.deserialize);
        list.queue_draw ();
    }
}