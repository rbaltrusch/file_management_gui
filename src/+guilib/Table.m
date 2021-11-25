classdef Table < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uitable(varargin{:});
            styler.style_table(widget);
        end
    end
end
