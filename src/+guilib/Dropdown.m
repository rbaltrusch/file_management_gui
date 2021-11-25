classdef Dropdown < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uidropdown(varargin{:});
            styler.style_dropdown(widget);
        end
    end
end
