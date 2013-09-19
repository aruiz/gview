namespace Data
{
  public interface Model : Object
  {
    public abstract ulong  n_items  {get; set;}

    public signal   void   modified (ulong position, ulong removed, ulong inserted);
    public abstract Object get_item (ulong index);
  }

  public interface RowDelegate : Gtk.Bin
  {
    public abstract Model model {get; set;}
    public abstract ulong index  {get; set;}
  }

  class ListView : Gtk.Container, Gtk.Scrollable
  {
    //Internal geometry
    private int real_height;
    private int real_width;
    private int average_height = 0;

    private List<RowDelegate> row_cache = null;

    //TODO: Consider the ability to set the cache size
    private Model ?            _model    = null;

    //RowDelegate class
    private Type _row_delegate_class;
    public  Type  row_delegate_class { get {return _row_delegate_class;} }

    //Gtk.Scrollable properties
    private Gtk.Adjustment _vadjustment;
    public Gtk.Adjustment vadjustment {
      set
      {
        int min;
        int nat;

        double val = 0;
        double lower = 0;
        double upper;
        //TODO: step/page increment?
        double step_increment = 1;
        double page_increment  = 1;
        double page_size;

        if (_hadjustment != null)
          _vadjustment.value_changed.disconnect (vadj_value_chanched_cb);

        get_preferred_height (out min, out nat);
        upper = (double)nat;
        page_size = 10;


        if (value == null)
          _vadjustment = new Gtk.Adjustment (val, lower, upper,
                                             step_increment, page_increment, page_size);
        else
          _vadjustment = value;
      }

      get
      {
        return _vadjustment;
      }
    }

    private Gtk.Adjustment _hadjustment;
    public Gtk.Adjustment hadjustment {
      set
      {
        int min;
        int nat;

        if (_hadjustment != null)
          _hadjustment.value_changed.disconnect (hadj_value_changed_cb);

        _hadjustment = value;
        _hadjustment.value_changed.connect (hadj_value_changed_cb);
        get_preferred_width (out min, out nat);
        _hadjustment.set_lower (0);
        _hadjustment.set_upper ((double)nat);
        _vadjustment.set_value (0);
      }
      get
      {
        return _hadjustment;
      }
    }

    public Gtk.ScrollablePolicy vscroll_policy {set;get;}
    public Gtk.ScrollablePolicy hscroll_policy {set;get;}

    public Model model {
      get
      {
        return _model;
      }
      set
      {
        if (this._model != null)
        {

        }

        _model = value;
        //TODO: Put the adjustments to the origin
        reset_cache ();
        _model.modified.connect (modified_cb);
      }
    }

    construct
    {
      set_has_window (false);
    }

    public ListView (Model model, Type row_delegate_class)
    {
       assert (row_delegate_class.is_a (typeof (RowDelegate)));
       this._row_delegate_class = row_delegate_class;

       this.model = model;
    }

    private void reset_cache ()
    {
      for (ulong i = 0; i < _model.n_items; i++)
        append_cache_item (i);
    }

    private void append_cache_item (ulong i)
    {
      var widget = Object.new (_row_delegate_class, "model", _model, "index", i) as Data.RowDelegate;

      widget.set_parent (this);
      row_cache.append (widget);

      //TODO: Asses visibility
      widget.set_child_visible (true);
    }

    private void remove_cache_item (ulong i)
    {
      unowned List<RowDelegate> item = row_cache.nth ((int)i);
      item.data.unparent ();
      row_cache.remove_link (item);
    }

    private void modified_cb (ulong position, ulong removed, ulong inserted)
    {
      if (inserted == 0 && removed == 0)
      {
        warning ("DataModel::modified was emitted with no insertion and no removals");
        return;
      }

      //TODO: Check if affects any of the cache items or not
      //TODO: Check cache size
      if (removed > 0)
        for (ulong i = 0; i < removed;   i++)
          remove_cache_item (position);
      if (inserted > 0)
        for (ulong i = 0; i < inserted; i++)
          append_cache_item (position + i);

      for (ulong i = position + inserted ; i < row_cache.length (); i++)
        row_cache.nth_data ((int)i).index = i;
      show_all ();
    }

    private void vadj_value_chanched_cb (Gtk.Adjustment adj)
    {
    }

    private void hadj_value_changed_cb (Gtk.Adjustment adj)
    {
    }

    public override void add (Gtk.Widget widget)
    {
      warning ("Widgets cannot be directly added");
    }

    public override void remove (Gtk.Widget widget)
    {
      warning ("Widgets cannot be directly removed");
    }

    public override void forall_internal (bool include_internals, Gtk.Callback cb)
    {
      for (int i = 0; i < row_cache.length (); i++)
        cb (row_cache.nth_data (i) as Gtk.Widget);
    }

    public override void get_preferred_width (out int min_width, out int nat_width)
    {
      min_width = 0;
      nat_width = 0;

      if (row_cache.length () == 0)
              return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data (i);
        widget.get_preferred_width (out tmp_min, out tmp_nat);
        if (tmp_nat > nat_width)
          nat_width = tmp_nat;
        if (tmp_min > min_width)
          min_width = tmp_min;
      }
    }

    public override void get_preferred_height (out int min_height, out int nat_height)
    {
      min_height = 0;
      nat_height = 0;

      if (row_cache.length ()== 0)
        return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data (i);
        widget.get_preferred_height (out tmp_min, out tmp_nat);
        nat_height += tmp_nat;
        min_height += tmp_min;
      }

      average_height = nat_height / (int)row_cache.length ();
    }

    public override void get_preferred_width_for_height (int height, out int min_width, out int nat_width)
    {
      min_width = 0;
      nat_width = 0;

      if (row_cache.length ()== 0)
              return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data (i);
        widget.get_preferred_width_for_height (height, out tmp_min, out tmp_nat);
        if (tmp_nat > nat_width)
          nat_width = tmp_nat;
        if (tmp_min > min_width)
          min_width = tmp_min;
      }
    }

    public override void get_preferred_height_for_width (int width, out int min_height, out int nat_height)
    {
      min_height = 0;
      nat_height = 0;

      if (row_cache.length () == 0)
        return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data (i);
        widget.get_preferred_height_for_width (width, out tmp_min, out tmp_nat);
        nat_height += tmp_nat;
        min_height += tmp_min;
      }
    }

    public override void size_allocate (Gtk.Allocation allocation)
    {
      base.size_allocate (allocation);

      if (row_cache.length () == 0)
        return;

      allocation.height = average_height;
      for (int i = 0; i < row_cache.length (); i++)
      {
        row_cache.nth_data (i).size_allocate (allocation);
        allocation.y += average_height;
      }
    }
  }
}

namespace Test {
  public class MyRow : Data.RowDelegate, Gtk.Bin
  {
    //TODO: Reuse the widget
    private ulong _index = 0;
    private bool index_set = false;
    private Data.Model? _model = null;
    public Data.Model model {
      get {return _model;}
      set
      {
        _model = value;
        if (index_set)
        {
          if (get_child () != null)
            remove (get_child ());
          add(new Gtk.Button.with_label ((_model.get_item (index) as MyItem).some_data));
          (get_child() as Gtk.Button).clicked.connect(() => { warning ("%d", (int)_index); });
        }
      }
    }

    public ulong index {
      get
      {
        return _index;
      }
      set
      {
        _index = value;
        index_set = true;
        if (_model != null)
        {
          if (get_child () != null)
            remove (get_child ());
          add(new Gtk.Button.with_label ("%d - %d".printf((int)_index, (int)(_model.get_item (index) as MyItem).index)));
          (get_child() as Gtk.Button).clicked.connect(() => { warning ("%d", (int)_index); });
        }
      }
    }

    construct {

    }
  }

  public class MyItem : Object
  {
    public string some_data = "http://www.lolcats.com/images/u/12/52/allforme.jpg";
    public ulong index;

    public MyItem (ulong index)
    {
      this.index = index;
    }
  }

  public class MyModel : Data.Model, Object
  {
    public ulong n_items { get; set; }

    construct {
      n_items = 100;
    }

    //TODO: Think about the ownership transfership on this method
    public Object get_item (ulong index)
    {
      return new MyItem (index) as Object;
    }

    public void add_item ()
    {
      n_items += 1;
      modified (n_items - 1, 0, 1);
    }

    public void remove_item ()
    {
      if (n_items == 0)
        return;

      if (n_items < 3)
      {
        n_items -= 1;
        modified (0, 1, 0);
        return;
      }

      n_items -= 3;
      modified (1, 3, 0);
    }
  }

  public static int main (string[] args)
  {
    Gtk.init (ref args);

    var model = new MyModel();

    var w = new Gtk.Window (Gtk.WindowType.TOPLEVEL);
    var sw = new Gtk.ScrolledWindow (null, null);
    sw.add (new Data.ListView(model, typeof (MyRow)));
    w.add(sw);
    w.show_all ();

    Gtk.main ();
    return 0;
  }
}
