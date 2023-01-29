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

    public He.IconicButton close_button;

    private string NOT_FOUND_TEXT = _("Not Found");

    public Wikipedia () {
        this.set_orientation(Gtk.Orientation.VERTICAL);
        this.set_spacing(12);

        close_button = new He.IconicButton ("window-close-symbolic") {
            halign = Gtk.Align.END
        };

        title_label = new Gtk.Label("");
        title_label.get_style_context().add_class("wk-title");
        title_label.halign = Gtk.Align.START;
        extract_label = new Gtk.Label("");
        extract_label.halign = Gtk.Align.START;
        extract_label.set_max_width_chars(200);
        extract_label.set_wrap(true);
        extract_label.justify = Gtk.Justification.FILL;

        link_button = new Gtk.LinkButton.with_label("https://wikipedia.org", "Wikipedia");
        link_button.halign = Gtk.Align.CENTER;

        this.append(close_button);
        this.append(title_label);
        this.append(extract_label);
        this.append(link_button);

        link_button.hide();
    }

    public void set_wikipedia_entry (WikipediaEntry entry) {
        title_label.set_text(entry.title);
        if(entry.extract != null && entry.extract.length > 0) {
            extract_label.set_text (entry.extract.replace("\n", "\n\n"));
            link_button.set_uri(entry.url);
            link_button.show();
            extract_label.show();
            article_changed(true);

        } else {
            extract_label.hide();
            link_button.hide();
            title_label.set_text(NOT_FOUND_TEXT);
            article_changed(false);
        }
    }

    public string get_link() {
        return link_button.get_uri();
    }
}