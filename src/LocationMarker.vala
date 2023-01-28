public class Aqui.LocationMarker : Shumate.Marker {

    public LocationMarker () {
        try {
            var pixbuf = new Gdk.Pixbuf.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR));
            var image = new Clutter.Image ();
            image.set_data (pixbuf.get_pixels (),
                          pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                          pixbuf.width,
                          pixbuf.height,
                          pixbuf.rowstride);
            content = image;
            set_size (pixbuf.width, pixbuf.height);
            translation_x = -pixbuf.width / 2;
            translation_y = -pixbuf.height;
        } catch (Error e) {
            critical (e.message);
        }
    }

}
