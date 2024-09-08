public class Aqui.LocationMarker : Shumate.Marker {
    public LocationMarker () {
        var image = new Gtk.Image.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR));
        image.pixel_size = 32;
        set_child(image);
    }
}
