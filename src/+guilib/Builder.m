classdef Builder < handle
    properties
        styler
        root
    end

    methods(Access = public)
        function obj = Builder(styler)
            obj.styler = styler;
        end

        function widget = create_button(obj, text, callback, rows, cols, varargin)
            widget = obj.create_widget(@guilib.Button, rows, cols, ...
                'ButtonPushedFcn', callback, 'Text', text, varargin{:});
        end

        function widget = create_text(obj, text, rows, cols, varargin)
            widget = obj.create_widget(@guilib.Text, rows, cols, ...
                'Value', text, 'Editable', 'off', varargin{:});
        end
        
        function widget = create_edit(obj, text, rows, cols, varargin)
            widget = obj.create_widget(@guilib.Edit, rows, cols, 'Value', text, varargin{:});
        end

        function widget = create_dropdown(obj, options, rows, cols, varargin)
            widget = obj.create_widget(@guilib.Dropdown, rows, cols, 'Items', options, varargin{:});
        end

        function widget = create_checkbox(obj, text, value, rows, cols, varargin)
            widget = obj.create_widget(@guilib.Checkbox, rows, cols, 'Text', text, 'Value', value, varargin{:});
        end

        function widget = create_widget(obj, factory_class, rows, cols, varargin)
            %Instantiation required because dot indexing is not supported for function handles.
            factory = factory_class();

            widget = factory.create_widget(obj.styler, obj.root, varargin{:});
            widget.Layout.Row = rows;
            widget.Layout.Column = cols;
        end
    end
end
