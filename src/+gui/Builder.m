%Handles creation of widgets (e.g. uibutton) to be added to an uifigure or
%uigridlayout root object.
%
%Expects an RGB colour 3x1 matrix normalised between 0 and 1 as input arg.
%
%Author: Richard Baltrusch
%Date: 27/11/2021

classdef Builder < handle
    properties
        root
        colour
    end

    methods(Access = public)
        function obj = Builder(colour)
            obj.colour = colour;
        end

        function widget = create_button(obj, text, callback, rows, cols, varargin)
            widget = obj.create_widget(@uibutton, rows, cols, ...
                'ButtonPushedFcn', callback, 'Text', text, varargin{:});
            widget.BackgroundColor = obj.colour;
        end

        function widget = create_text(obj, text, rows, cols, varargin)
            widget = obj.create_widget(@uitextarea, rows, cols, ...
                'Value', text, 'Editable', 'off', varargin{:});
            widget.BackgroundColor = obj.colour;
        end
        
        function widget = create_edit(obj, text, rows, cols, varargin)
            widget = obj.create_widget(@uieditfield, rows, cols, 'Value', text, varargin{:});
        end

        function widget = create_dropdown(obj, options, rows, cols, varargin)
            widget = obj.create_widget(@uidropdown, rows, cols, 'Items', options, varargin{:});
            widget.BackgroundColor = obj.colour;
        end

        function widget = create_checkbox(obj, text, value, rows, cols, varargin)
            widget = obj.create_widget(@uicheckbox, rows, cols, 'Text', text, 'Value', value, varargin{:});
        end

        function widget = create_widget(obj, factory_function, rows, cols, varargin)
            %Instantiation required because dot indexing is not supported for function handles.
            widget = factory_function(obj.root, varargin{:});
            widget.Layout.Row = rows;
            widget.Layout.Column = cols;
        end
    end
end
