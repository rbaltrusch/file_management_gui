classdef Button < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uibutton(varargin{:});
            styler.style_button(widget);
        end
    end
end
