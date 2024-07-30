public class WikipediaEntry {
    public string title = "";
    public string extract = "";
    public int64 pageid = 0;
    public string url = "";
    public string pic = "";

    public WikipediaEntry () {}
}

public class Aqui.Wikipedia : Gtk.Box {
    public signal void article_changed (bool found);

    private Gtk.Label title_label;
    private Gtk.Label extract_label;
    private Gtk.LinkButton link_button;
    private He.ContentBlockImage picture;

    public He.Button close_button;
    public Gtk.ToggleButton fav_button;

    private string NOT_FOUND_TEXT = _("Not Found");
    private string NOT_FOUND_SUBT = _("The specified location was not found, either because network is offline or the place doesn't have a Wikipedia page.");

    public Wikipedia () {
        this.set_orientation(Gtk.Orientation.VERTICAL);
        this.set_spacing(12);

        close_button = new He.Button ("window-close-symbolic", null) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START
        };
        close_button.add_css_class ("small-cb");

        picture = new He.ContentBlockImage ("") {
            requested_height = 180,
            requested_width = 300
        };
        picture.add_css_class ("pix");

        var picture_overlay = new Gtk.Overlay ();
        picture_overlay.add_overlay (close_button);
        picture_overlay.set_child (picture);

        title_label = new Gtk.Label("") {
            halign = Gtk.Align.START
        };
        title_label.get_style_context().add_class("wk-title");

        link_button = new Gtk.LinkButton.with_label("https://wikipedia.org", "Wikipedia") {
            halign = Gtk.Align.END,
            hexpand = true
        };
        link_button.remove_css_class ("link");
        link_button.remove_css_class ("text-button");
        link_button.add_css_class ("txt");

        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        title_box.append (title_label);
        title_box.append (link_button);

        extract_label = new Gtk.Label("") {
            valign = Gtk.Align.START,
            wrap = true,
            vexpand = true,
            use_markup = true
        };

        var sw = new Gtk.ScrolledWindow () {
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = Gtk.PolicyType.NEVER
        };
        sw.set_child (extract_label);

        var sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        fav_button = new Gtk.ToggleButton () {
            halign = Gtk.Align.END,
            valign = Gtk.Align.CENTER,
            hexpand = true,
            margin_end = 12,
            margin_bottom = 12,
            child = new He.ButtonContent () {
                label = (_("Favorite")),
                icon = "emblem-favorite-symbolic"
            }
        };
        fav_button.add_css_class ("tint-button");
        fav_button.add_css_class ("pill-button");

        this.append(picture_overlay);
        this.append(title_box);
        this.append(sw);
        // this.append(sep);
        // this.append(fav_button);

        link_button.hide();
        picture.hide ();
    }

    public void set_wikipedia_entry (WikipediaEntry entry) {
        title_label.set_text(entry.title);
        if(entry.extract != "" && entry.extract.length > 0) {
            extract_label.set_text (entry.extract.replace("\n", "\n\n"));
            link_button.set_uri(entry.url);
            link_button.show();
            picture.file = entry.pic;
            picture.show();
            article_changed(true);
        } else {
            extract_label.set_text(NOT_FOUND_SUBT);
            link_button.hide();
            title_label.set_text(NOT_FOUND_TEXT);
            picture.hide ();
            article_changed(false);
        }
    }

    public string get_link() {
        return link_button.get_uri();
    }
}