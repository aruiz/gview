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
  }

  public interface RowDelegate : Gtk.Bin
  {
    public abstract Model model {get; set;}
  }

  class ListView : Gtk.Container
  {

    private RowDelegate[]? row_cache = null;
    private Model? _model = null;

    public Model model { get {return _model;} set {_model = value;}}

    construct
    {
      set_has_window (false);
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

  public static int main (string[] args)
  {
    Gtk.init (ref args);

    var w = new Gtk.Window (Gtk.WindowType.TOPLEVEL);
    w.add (new ListView());
    w.show_all ();

    Gtk.main ();
    return 0;
  }
}
