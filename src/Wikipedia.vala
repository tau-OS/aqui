public class WikipediaEntry {
    public string title = "";
    public string extract = "";
    public int64 pageid = 0;
    public string url = "";

    public WikipediaEntry () {}
}

public class Aqui.Wikipedia : Gtk.Box {
    public signal void article_changed (bool found);

    private Gtk.Label title_label;
    private Gtk.Label extract_label;
    private Gtk.LinkButton link_button;

    public He.DisclosureButton close_button;

    private string NOT_FOUND_TEXT = _("Not Found");
    private string NOT_FOUND_SUBT = _("The specified location was not found, either because network is offline or the place doesn't have a Wikipedia page.");

    public Wikipedia () {
        this.set_orientation(Gtk.Orientation.VERTICAL);
        this.set_spacing(12);

        close_button = new He.DisclosureButton ("window-close-symbolic") {
            halign = Gtk.Align.END
        };
        close_button.remove_css_class ("image-button");
        close_button.add_css_class ("small-cb");

        title_label = new Gtk.Label("") {
            halign = Gtk.Align.START
        };
        title_label.get_style_context().add_class("wk-title");

        link_button = new Gtk.LinkButton.with_label("https://wikipedia.org", "Wikipedia") {
            halign = Gtk.Align.END
        };

        var title_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        title_box.append (title_label);
        title_box.append (link_button);

        extract_label = new Gtk.Label("") {
            valign = Gtk.Align.START,
            max_width_chars = 370,
            wrap = true,
            justify = Gtk.Justification.FILL,
            vexpand = true
        };

        var sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        this.append(close_button);
        this.append(title_box);
        this.append(extract_label);
        this.append(sep);

        link_button.hide();
    }

    public void set_wikipedia_entry (WikipediaEntry entry) {
        title_label.set_text(entry.title);
        if(entry.extract != null && entry.extract.length > 0) {
            extract_label.set_text (entry.extract.replace("\n", "\n\n"));
            link_button.set_uri(entry.url);
            link_button.show();
            article_changed(true);

        } else {
            extract_label.set_text(NOT_FOUND_SUBT);
            link_button.hide();
            title_label.set_text(NOT_FOUND_TEXT);
            article_changed(false);
        }
    }

    public string get_link() {
        return link_button.get_uri();
    }
}