public class LocationResult : He.Bin {
    public Geocode.Place place { get; construct; }

    public LocationResult (Geocode.Place place) {
        Object (
                place: place
        );
    }

    construct {
        var box = new He.MiniContentBlock ();
        box.title = place.name;
        box.subtitle = place.country ?? "";
        box.icon = "location-active-symbolic";
        box.hexpand = true;

        child = box;
    }
}