namespace Aqui.Spinner {
    public static void activate (Gtk.Spinner instance, string reason) {
        instance.tooltip_text = reason;
        instance.show ();
        instance.start ();
    }

    public static void deactivate (Gtk.Spinner instance) {
        instance.hide ();
        instance.stop ();
    }
}
