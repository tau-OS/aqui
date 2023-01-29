namespace Aqui {
    public interface Utils.ContentItem : GLib.Object {
        public abstract string? name { get; set; }
        public abstract void serialize (GLib.VariantBuilder builder);
    }
    
    public class Utils.ContentStore : GLib.Object, GLib.ListModel {
        private ListStore store;
        private CompareDataFunc<ContentItem>? sort_func;
    
    
        public ContentStore () {
            store = new ListStore (typeof (ContentItem));
            store.items_changed.connect ((position, removed, added) => {
                items_changed (position, removed, added);
            });
        }
    
        public Type get_item_type () {
            return store.get_item_type ();
        }
    
        public uint get_n_items () {
            return store.get_n_items ();
        }
    
        public Object? get_item (uint position) {
            return store.get_item (position);
        }
    
        public void set_sorting (owned CompareDataFunc<ContentItem> sort) {
            sort_func = (owned) sort;
            assert (store.get_n_items () == 0);
        }
    
        public void add (ContentItem item) {
            if (sort_func == null) {
                store.append (item);
            } else {
                store.insert_sorted (item, sort_func);
            }
        }
    
        public void prepend (ContentItem item) {
            store.insert (0, item);
        }
    
        public int get_index (ContentItem item) {
            int position = -1;
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var compared_item = (ContentItem) store.get_object (i);
                if (compared_item == item) {
                    position = i;
                    break;
                }
            }
            return position;
        }
    
        public void remove (ContentItem item) {
            var index = get_index (item);
            if (index != -1) {
                store.remove (index);
            }
        }
    
        public delegate void ForeachFunc (ContentItem item);
    
        public void foreach (ForeachFunc func) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                func ((ContentItem) store.get_object (i));
            }
        }
    
        public delegate bool FindFunc (ContentItem item);
        public ContentItem? find (FindFunc func) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var item = (ContentItem) store.get_object (i);
                if (func (item)) {
                    return item;
                }
            }
            return null;
        }
    
        public void delete_item (ContentItem item) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var o = store.get_object (i);
                if (o == item) {
                    store.remove (i);
    
                    if (sort_func != null) {
                        store.sort (sort_func);
                    }
    
                    return;
                }
            }
        }
    
        public Variant serialize () {
            var builder = new GLib.VariantBuilder (new VariantType ("aa{sv}"));
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                ((ContentItem) store.get_object (i)).serialize (builder);
            }
            return builder.end ();
        }
    
        public delegate ContentItem? DeserializeItemFunc (Variant v);
    
        public void deserialize (Variant variant, DeserializeItemFunc deserialize_item) {
            Variant item;
            var iter = variant.iterator ();
            while (iter.next ("@a{sv}", out item)) {
                ContentItem? i = deserialize_item (item);
                if (i != null) {
                    add ((ContentItem) i);
                }
            }
        }
    }
}