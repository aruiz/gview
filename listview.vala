namespace Data
{
/*  class View : Gtk.Widget, Gtk.Scrollable
  {
    public Gtk.Adjustment vadjustment {set;get;}
    public Gtk.Adjustment hadjustment {set;get;}

    public Gtk.ScrollablePolicy vscroll_policy {set;get;}
    public Gtk.ScrollablePolicy hscroll_policy {set;get;}

    private Model.List? _model = null;
    public Model.List? model
    {
      set
      {
        _model = value;
        model_changed (_model);
      }
      get {return _model;}
    }
    public signal void model_changed (Model.List model);

    public View (Model.List? model = null)
    {
      this.model = model;
      draw.connect (draw_cb);
      set_has_window (false);
    }

    bool draw_cb (Cairo.Context ct)
    {
      Gtk.Allocation alloc;
      get_allocation (out alloc);

      message ("%d %d %d %d", alloc.x, alloc.width, alloc.y, alloc.height);
      return true;
    }
  }*/

  public interface Model : Object
  {
    public abstract ulong n_items {get; set;}
    public signal void modified (ulong position, ulong removed, ulong inserted);
    public abstract Object get_item (ulong index);
  }

  public interface RowDelegate : Gtk.Bin
  {
    public abstract Model model {get; set;}
  }

  class ListView : Gtk.Container, Gtk.Scrollable
  {
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
        this._model = model;
      }
    }

    public Type row_delegate_class { get; construct;}

    construct
    {
      set_has_window (false);
    }

    public ListView (Model model, Type row_delegate_class)
    {
       this.model = model;
       //TODO: Check that Type implements RowDelegate

       //TODO: Chech that n_items is not ULONG_MAX
       for (ulong i = 0; i < model.n_items; i++)
       {

       }
    }

    public override void get_preferred_width (out int min_width, out int nat_width)
    {
    }

    public override void get_preferred_height (out int min_height, out int nat_height)
    {
    }

    public override void get_preferred_width_for_height (int height, out int min_width, out int nat_width)
    {
    }

    public override void get_preferred_height_for_width (int width, out int min_height, out int nat_height)
    {
    }

    public override void size_allocate (Gtk.Allocation allocation)
    {
      base.size_allocate (allocation);
    }
  }
}

namespace Test {
  public class MyRow : Data.RowDelegate, Gtk.Bin
  {
    public Data.Model model {get;set;}

    construct {
      add(new Gtk.Button.with_label ("asdasd"));
    }
  }

  public class MyModel : Data.Model, Object
  {
    public  ulong n_items { get; set; }

    construct {
      n_items = 5;
    }

    public  Object get_item (ulong index)
    {
      return this as Object;
    }
  }


  public static int main (string[] args)
  {
    Gtk.init (ref args);

    var model = new MyModel();

    var w = new Gtk.Window (Gtk.WindowType.TOPLEVEL);
    w.add (new Data.ListView(model, typeof (MyRow)));
    w.show_all ();

    Gtk.main ();
    return 0;
  }
}
