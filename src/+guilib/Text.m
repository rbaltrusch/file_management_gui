classdef Text < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uitextarea(varargin{:});
            styler.style_text(widget);
        end
    end
end
