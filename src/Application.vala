public class Aqui.Application : He.Application {
    public static Settings settings;

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: Build.PROJECT_NAME
        );
    }

    static construct {
        settings = new Settings (Build.PROJECT_NAME);
    }

    protected override void startup () {
        Gdk.RGBA accent_color = { 0 };
        accent_color.parse("#49d05e");
        default_accent_color = He.Color.from_gdk_rgba(accent_color);

        resource_base_path = "/com/fyralabs/Aqui";

        base.startup ();

        var mw = new MainWindow (this);

        settings.bind ("window-height", mw, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", mw, "default-width", SettingsBindFlags.DEFAULT);
        if (settings.get_boolean ("maximized")) {
            mw?.maximize ();
        }
        settings.bind ("maximized", mw, "maximized", SettingsBindFlags.SET);

        double lat, lon;
        settings.get("last-viewed-location", "(dd)", out lat, out lon);

        if (lat >= -85.05112 && lat <= 85.05112 &&
            lon >= -180 && lon <= 180) {
                mw?.smap.get_map ().get_viewport ().latitude = lat;
                mw?.smap.get_map ().get_viewport ().longitude = lon;
        }
    }

    protected override void activate () {
        active_window?.present ();
    }

    public static int main (string[] args) {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Build.PROJECT_NAME, Build.LOCALEDIR);
        Intl.bind_textdomain_codeset (Build.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Build.PROJECT_NAME);

        var app = new Aqui.Application ();
        return app.run (args);
    }
}
