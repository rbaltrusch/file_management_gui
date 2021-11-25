classdef Checkbox < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uicheckbox(varargin{:});
            styler.style_checkbox(widget);
        end
    end
end
