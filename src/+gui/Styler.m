classdef Styler < handle
    properties(Constant)
        colour = [150 150 255] / 256;
    end

    methods(Access = public)
        function style_button(obj, widget)
            widget.BackgroundColor = obj.colour;
        end

        function style_dropdown(obj, widget)
            widget.BackgroundColor = obj.colour;
        end

        function style_text(obj, widget)
            widget.BackgroundColor = obj.colour;
        end

        function style_edit(~, ~)
        end

        function style_table(~, ~)
        end

        function style_checkbox(~, ~)
        end
    end
end
