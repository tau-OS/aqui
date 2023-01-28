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

        new MainWindow (this);
    }

    protected override void activate () {
        active_window?.present ();

        settings.bind ("window-height", active_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", active_window, "default-width", SettingsBindFlags.DEFAULT);
        if (settings.get_boolean ("maximized")) {
            active_window?.maximize ();
        }
        settings.bind ("maximized", active_window, "maximized", SettingsBindFlags.SET);
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
