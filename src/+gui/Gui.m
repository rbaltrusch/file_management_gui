%This GUI combines three common file management tasks:
%
%   1) Copy all selected files from a specified directory to a new, specified directory
%   2) Move all selected files from a specified directory to a new, specified directory
%   3) Delete all selected files from a specified directory and move them to the Recycle bin.
%
%
%The files to be used in those tasks can be selected by specifying a
%globbing filter, defaulting to * (matches everything) and filtered using
%the filter button. Recursive search (i.e. including subdirectories) can be
%toggled using the recursive checkbox. All files found are shown in the
%file table.
%
%The GUI provides renaming functionality for moved or copied files:
%
%   1) Add a prefix to all selected files (e.g. if prefix = hello, then a
%   selected file called world.txt would be renamed helloworld.txt once
%   copied/moved to the new folder.
%
%   2) Add a suffix to all selected files (e.g. if suffix = world, then a
%   selected file called hello.txt would be renamed helloworld.txt once
%   copied/moved to the new folder.
%
%   3) Find and replace a substring. For example, if the find expression is
%   "h" and the replace expression is "g", a file called help.txt would be
%   renamed to gelp.txt. Regexp matching can be used for find and replace
%   by enabling the regexp checkbox.
%
%If the "rename duplicate files" checkbox is enabled, files with matching
%names will be renamed in the destination folder by adding a numebr suffix.
%It is recommended to keep it enabled, otherwise data may be overwritten in
%the destination folder.
%
%
%The source and destination directories can be specified either using their
%respective buttons or text boxes.
%
%Author: Richard Baltrusch
%Date: 27/11/2021

classdef Gui < handle
    properties(Access = public)
        builder
        widgets containers.Map
        fig matlab.ui.Figure
    end

    properties(Access = private)
        dest_folder = pwd
        confirm
    end

    methods(Access = public)
        function obj = Gui(varargin)
            parser = inputParser;
            addRequired(parser, 'builder', @(~) true);
            addParameter(parser, 'confirm', true, @islogical)
            parser.parse(varargin{:});

            obj.builder = parser.Results.builder;
            obj.confirm = parser.Results.confirm;
            obj.widgets = containers.Map;
        end

        function build(obj)
            obj.fig = uifigure('Name', 'File Management GUI', 'Position', [500 100 505 520]);
            obj.builder.root = uigridlayout(obj.fig, ...
                'RowHeight', {40, 20, 20, 150, 20, 50, 20, 20, 20, 20, 20}, ...
                'ColumnWidth', {45, 100, 100, 100, 100});

            %title text
            obj.builder.create_edit('File Management GUI', 1, [1 5], 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'FontSize', 25, 'Editable', 'off', ...
                'BackgroundColor', obj.builder.colour);

            %source folder
            obj.builder.create_text('From:', 2, 1);
            obj.widgets('source_folder') = obj.builder.create_edit(pwd, 2, [2 4]);
            obj.builder.create_button('Select folder', @obj.select_source_folder, 2, 5);
            
            %filter
            obj.builder.create_text('Filter files:', 3, [1 2]);
            obj.widgets('filter') = obj.builder.create_edit('*', 3, 3);
            obj.widgets('recursive') = obj.builder.create_checkbox('Recursive', true, 3, 4);
            obj.widgets('filter_btn') = obj.builder.create_button('Filter', @obj.filter_files, 3, 5);

            %file table
            obj.widgets('table') = obj.builder.create_widget(@uitable, 4, [1 5]);

            %destination folder
            obj.widgets('to') = obj.builder.create_text('To:', 5, 1);
            obj.widgets('dest_folder') = obj.builder.create_edit(pwd, 5, [2 4], 'ValueChangedFcn', @obj.dest_folder_changed);
            obj.widgets('dest_select') = obj.builder.create_button('Select folder', @select_destination_folder, 5, 5);

            %function dropdown
            options = {'Copy files', 'Move files', 'Delete files'};
            obj.widgets('function') = obj.builder.create_dropdown(options, 6, [1 4], ...
                'ValueChangedFcn', @obj.function_dropdown_changed, 'FontSize', 13);

            %find, replace, prefix, suffix
            obj.widgets('rename_title') = obj.builder.create_text('Rename at destination', 7, [1 4]);
            obj.widgets('find_text') = obj.builder.create_text('Find:', 8, [1 2]);
            obj.widgets('find') = obj.builder.create_edit('', 8, [3 4]);
            obj.widgets('replace_text') = obj.builder.create_text('Replace:', 9, [1 2]);
            obj.widgets('replace') = obj.builder.create_edit('', 9, [3 4]);
            obj.widgets('prefix_text') = obj.builder.create_text('Prefix:', 10, 3);
            obj.widgets('prefix') = obj.builder.create_edit('', 10, 4);
            obj.widgets('suffix_text') = obj.builder.create_text('Suffix:', 11, 3);
            obj.widgets('suffix') = obj.builder.create_edit('', 11, 4);

            %checkboxes
            obj.widgets('regexp') = obj.builder.create_checkbox('Use regexp', false, 10, [1 2]);
            obj.widgets('rename_duplicate') = obj.builder.create_checkbox('Rename duplicate files', true, 11, [1 2]);

            obj.widgets('run_btn') = obj.builder.create_button('Run', @obj.run_selected_function, ...
                [6 11], 5, 'FontSize', 19, 'FontWeight', 'bold');
            
            uibutton(obj.fig, 'Text', '?', 'ButtonPushedFcn', @obj.display_help_fig, ...
                'Position', [475 490 20 20], 'BackgroundColor', [80 80 255] / 256);
        end
    end

    methods(Access = private)
        function set_enable(obj, value, keys)
            try
                for c = 1:length(keys)
                    component = obj.widgets(keys{c});
                    component.Enable = value;
                end
            catch
                obj.emit_warning('EI1: An internal error occured while setting gui enables');
            end
        end
        
        function function_dropdown_changed(obj, widget, ~)
            %Callback for value change of functions dropdown
            components = {'to', 'dest_folder', 'dest_select', 'rename_title', 'find_text', ...
                'find', 'replace_text', 'replace', 'prefix_text', 'prefix', 'suffix_text', ...
                'suffix', 'regexp', 'rename_duplicate'};
            delete_flag = strcmp(widget.Value, 'Delete files');
            obj.set_enable(~delete_flag, components);

            edit = obj.widgets('dest_folder');
            if delete_flag
                edit.Value = 'RecycleBin';
            elseif strcmp(edit.Value, 'RecycleBin')
                edit.Value = obj.dest_folder;
            end
        end

        function dest_folder_changed(obj, widget, ~)
            %Callback for value change of dest folder edit
            if ~strcmp(widget.Value, 'RecycleBin')
                obj.dest_folder = widget.Value;
            end
        end

        function select_source_folder(obj, varargin)
            %Callback for select source folder button
            folder = obj.select_folder();
            if folder ~= 0
                widget = obj.widgets('source_folder');
                widget.Value = folder;
            end
        end
        
        function select_destination_folder(obj, varargin)
            %Callback for select destination folder button
            folder = obj.select_folder();
            if folder ~= 0
                widget = obj.widgets('dest_folder');
                widget.Value = folder;
            end
        end

        function folder = select_folder(obj)
            try
                folder = uigetdir();
                figure(obj.fig) %avoid staying in background after uigetdir
            catch
                obj.emit_warning('EB1: An error occured while selecting the folder');
            end
        end

        function files = filter_files(obj, varargin)
            %Callback for filter button
            try
                folder = obj.widgets('source_folder').Value;
                files = lib.filter_files(folder, ...
                    'filter', obj.widgets('filter').Value, ...
                    'recursive', obj.widgets('recursive').Value);
            catch
                obj.emit_warning('EB2: An error occured while filtering files');
            end

            try
                widget = obj.widgets('table');
                widget.Data = files;
            catch
                obj.emit_warning('EB21: An error occured while adding filtered files to table!');
            end
        end

        function run_selected_function(obj, varargin)
            %Callback for run_button to run function selected in function select dropdown.
            try
                files_ = obj.filter_files();
                if strcmp('Delete files', obj.widgets('function').Value)
                    lib.delete_files(files_);
                else
                    mode = lower(regexp(obj.widgets('function').Value, '\w+?(?=\s)', 'match', 'once'));
                    
                    lib.copy_files(files_, ...
                        'folder', obj.widgets('dest_folder').Value, ...
                        'find', obj.widgets('find').Value, ...
                        'replace', obj.widgets('replace').Value, ...
                        'prefix', obj.widgets('prefix').Value, ...
                        'suffix', obj.widgets('suffix').Value, ...
                        'regexp', obj.widgets('regexp').Value, ...
                        'mode', mode);
                end
                obj.emit_info('Successfully ran the selected function');
            catch ME
                obj.emit_warning('EB3: An error occured while running the selected function');
            end
        end

        function display_help_fig(obj, varargin)
            %Callback for help button
            try
                text = help(mfilename('fullpath'));
                fig_ = uifigure('Name', 'Help', 'Position', [450 100 450 500]);
                uitextarea(fig_, 'Value', text, 'Position', [0 0 450 500], ...
                    'BackgroundColor', [200 200 255]/256);
            catch
                obj.emit_warning('An error occured while displaying the help figure');
            end
        end

        function emit_warning(obj, message)
            if obj.confirm
                uiwait(warndlg(message));
            else
                warning(message);
            end
        end

        function emit_info(obj, message)
            if obj.confirm
                uiwait(msgbox(message));
            else
                disp(message);
            end
        end
    end
end
