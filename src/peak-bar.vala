namespace Music {

    public class PeakBar : Gtk.Box {
    	private string _charsC = "⚝";
        private string _charsL = "⚞";
        private string _charsR = "⚟";
        private Pango.FontDescription _font = new Pango.FontDescription ();
        private StringBuilder _sbuilder = new StringBuilder ();
        private double _value = 0;
        private Pango.Layout _layout;

        public PeakBar () {
            _layout = create_pango_layout (null);
            _layout.set_font_description (_font);
        }

        public Pango.Alignment align {
            get {
                return _layout.get_alignment ();
            }
            set {
                _layout.set_alignment (value);
                queue_draw ();
            }
        }

        public void set_peak (double value) {
            if (_value != value) {
                _value = value;
                queue_draw ();
            }
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            var width = get_width ();
            var height = get_height ();
            _font.set_absolute_size (height * Pango.SCALE);
            _layout.set_width (width * Pango.SCALE);
            _layout.set_height (height * Pango.SCALE);

            Pango.Rectangle ink_rect, logic_rect;
            
            _layout.set_text (_charsC, _charsC.length);
            _layout.get_pixel_extents (out ink_rect, out logic_rect);

            var count = (int) (width * _value / logic_rect.width);
            
            if (count % 2 != 0)
                count++;
            
            _sbuilder.erase ();
                        
            if (_layout.get_alignment () == Pango.Alignment.CENTER) {
                
                var iter = 0;
            
                for (; iter < count/2; iter++)
                    _sbuilder.append (_charsL);
                
                _sbuilder.append (_charsC);

                for (; iter < count; iter++)
                    _sbuilder.append (_charsR);
            
            }

            else if (_layout.get_alignment () == Pango.Alignment.LEFT) {
            
                _sbuilder.append (_charsC);

                for (var i = 0; i < count/2; i++)
                    _sbuilder.append (_charsR);
                
            }
                
            unowned var text = _sbuilder.str;
            
            _layout.set_text (text, text.length);

            var style = get_style_context ();
            var color = style.get_color ();

            var pt = Graphene.Point ();
            
            pt.x = 0;
            pt.y = - ink_rect.y + (height - ink_rect.height) * 0.5f;
            
                    
            snapshot.translate (pt);
            snapshot.append_layout (_layout, color);
            
            pt.y = - pt.y;
            snapshot.translate (pt);
        }
    }
}
