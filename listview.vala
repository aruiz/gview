namespace View
{
  class View : Gtk.Widget, Gtk.Scrollable
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
  }

  public static int main (string[] args)
  {
    Gtk.init (ref args);

    var w = new Gtk.Window (Gtk.WindowType.TOPLEVEL);
    w.add (new View());
    w.show_all ();

    Gtk.main ();
    return 0;
  }
}
