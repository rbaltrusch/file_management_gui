classdef Edit < guilib.Widget
    methods(Access = public, Static)
        function widget = create_widget(styler, varargin)
            widget = uieditfield(varargin{:});
            styler.style_edit(widget);
        end
    end
end
