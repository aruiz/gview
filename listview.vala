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
    public abstract uint index  {get; set;}
  }

  class ListView : Gtk.Container, Gtk.Scrollable
  {
    //TODO: Consider the ability to set the cache size
    private int average_height = 0;
    private uint CACHE_SIZE   = 100;
    private List<RowDelegate> row_cache = null;
    private Model?            _model    = null;

    public Gtk.Adjustment vadjustment {set;get;}
    public Gtk.Adjustment hadjustment {set;get;}

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
        //TODO: Change the model of all the elements in the row cache
        reset_cache ();

        _model.modified.connect (modified_cb);
      }
    }

    private void modified_cb (ulong position, ulong removed, ulong inserted)
    {
      if (inserted == 0 && removed == 0)
      {
        warning ("DataModel::modified was emitted with no insertion and no removals");
        return;
      }
      if (inserted > 0 && inserted > 0)
      {
      }
      if (inserted > 0)
      {
        //TODO: Check if affects cache
        append_cache_item (position);
      }
      if (removed > 0)
      {
      }
    }

    private Type _row_delegate_class;
    public Type row_delegate_class { get {return _row_delegate_class;} }

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
       ulong n_items;

       if (_model.n_items > CACHE_SIZE)
         n_items = CACHE_SIZE;
       else
         n_items = _model.n_items;

       for (ulong i = 0; i < n_items; i++)
        append_cache_item (i);
    }

    private void append_cache_item (ulong i)
    {
      var widget = Object.new (_row_delegate_class, "model", _model, "index", i) as Data.RowDelegate;

      widget.show_all ();
      widget.set_parent (this);
      row_cache.append (widget);

      //TODO: Asses visibility
      widget.set_child_visible (true);
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
        var widget = row_cache.nth_data(i);
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

      if (row_cache.length () == 0)
        return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data(i);
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

      if (row_cache.length () == 0)
              return;

      for (int i = 0; i < row_cache.length (); i++)
      {
        int tmp_min, tmp_nat;
        var widget = row_cache.nth_data(i);
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
        var widget = row_cache.nth_data(i);
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
        row_cache.nth_data(i).size_allocate (allocation);
        allocation.y += average_height;
      }
    }
  }
}

namespace Test {
  public class MyRow : Data.RowDelegate, Gtk.Bin
  {
    //TODO: Reuse the widget
    private uint _index = 0;
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

    public uint index {
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
          add(new Gtk.Button.with_label ((_model.get_item (index) as MyItem).some_data));
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
  }

  public class MyModel : Data.Model, Object
  {
    public ulong n_items { get; set; }

    construct {
      n_items = 5;
    }

    public  Object get_item (ulong index)
    {
      return new MyItem () as Object;
    }

    public void add_item ()
    {
      n_items += 1;
      modified (n_items - 1, 0, 1);
    }
  }

  public static int main (string[] args)
  {
    Gtk.init (ref args);

    var model = new MyModel();
    Timeout.add (1000, () => {model.add_item (); return true;});

    var w = new Gtk.Window (Gtk.WindowType.TOPLEVEL);
    w.add (new Data.ListView(model, typeof (MyRow)));
    w.show_all ();

    Gtk.main ();
    return 0;
  }
}
