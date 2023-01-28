public class Aqui.LocationMarker : Shumate.Marker {
    public LocationMarker () {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR));
            var image = new Gtk.Image.from_pixbuf (pixbuf);
            image.pixel_size = 48;
            set_child(image);
        } catch (Error e) {
            critical (e.message);
        }
    }
}
