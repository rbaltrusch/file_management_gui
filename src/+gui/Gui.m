%This GUI combines three common file management tasks:
%
%   1) Copy all selected files from a specified directory* to a new, specified directory
%   2) Move all selected files from a specified directory* to a new, specified directory
%   3) Delete all selected files from a specified directory* to the Recycle bin.
%
%       * including subdirectories
%
%The files to be used in those tasks can be selected by specifying two
%filters: one for the file extension, one for the file name (labelled filter).
%Standard Windows wildcard characters (* and ?) may be used. Note that the
%file name filter does not work if no file extension is specified and it
%defaults to .*
%
%The directories specified (both source and destination) can be specified
%either by specifying the path in the text boxes provided (From = source,
%To = destination) or by selecting the relevant path using the select path
%button.
%
%The filter button searches in the folder specified and all of its
%subdirectories for the files that match the specified file name filter and
%file extension filter. The matched files then get displayed in the table
%in the middle of the GUI. Using the filter button is not required, but
%desireable to test whether the filters specified match the expected files.
%
%
%The GUI also provides file renaming functionality upon moving, copying or
%deleting the file to the new folder. This can be done in three ways:
%
%   1) Add a prefix to all selected files (e.g. if prefix = hello, then a
%   selected file called world.txt would be renamed helloworld.txt once
%   copied/moved to the new folder.
%
%   2) Add a suffix to all selected files (e.g. if suffix = world, then a
%   selected file called hello.txt would be renamed helloworld.txt once
%   copied/moved to the new folder.
%
%   3) Find and replace a substring using regexp expressions. For example,
%   if the find expression is "^h" and the replace expression is "y", all
%   files starting with "h" would have that "h" changed to "y", e.g.
%   help.txt --> yelp.txt
%
%
%The rename duplicate files checkbox enables or disables the duplicate file
%renaming functionality. If enabled, files that are moved to the new
%folder that have the same name as a file that already exist in that folder
%would be renamed by adding a number suffix, e.g. help.txt --> help1.txt.
%If the checkbox is unchecked, then files with the same name are
%overwritten, which may be undesirable if the files with the same name
%contain different data.
%
%Author: Richard Baltrusch
%Date: 25/11/2021

classdef Gui < handle
    properties(Access = private)
        builder
        widgets containers.Map
        fig matlab.ui.Figure
        dest_folder = pwd
    end

    methods(Access = public)
        function obj = Gui(builder)
            obj.builder = builder;
            obj.widgets = containers.Map;
        end

        function build(obj)
            obj.fig = uifigure('Name', 'File Management GUI', 'Position', [500 100 505 490]);
            obj.builder.root = uigridlayout(obj.fig, ...
                'RowHeight', {40, 20, 20, 20, 150, 20, 20, 20, 20, 50}, ...
                'ColumnWidth', {45, 100, 100, 100, 100});

            obj.builder.create_edit('File Management GUI', 1, [1 5], 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'FontSize', 25, 'Editable', 'off', ...
                'BackgroundColor', obj.builder.colour);

            %source folder
            obj.builder.create_text('From:', 2, 1);
            obj.widgets('source_folder') = obj.builder.create_edit(pwd, 2, [2 4]);
            obj.builder.create_button('Select folder', @obj.select_source_folder, 2, 5);
            
            %extension and filter
            obj.builder.create_text('Extension', 3, [1 2]);
            obj.widgets('extension') = obj.builder.create_edit('.*', 3, [3 4]);
            obj.builder.create_text('Filter expression', 4, [1 2]);
            obj.widgets('filter') = obj.builder.create_edit('*', 4, [3 4]);
            obj.builder.create_button('Filter', @obj.filter_files, [3 4], 5);

            %file table
            obj.widgets('table') = obj.builder.create_widget(@uitable, 5, [1 5]);

            %destination folder
            obj.widgets('to') = obj.builder.create_text('To:', 6, 1);
            obj.widgets('dest_folder') = obj.builder.create_edit(pwd, 6, [2 4], 'ValueChangedFcn', @obj.dest_folder_changed);
            obj.widgets('dest_select') = obj.builder.create_button('Select folder', @select_destination_folder, 6, 5);

            %checkboxes
            obj.widgets('rename_duplicate') = obj.builder.create_checkbox('Rename duplicate files', true, 7, [3 4]);
            obj.widgets('rename_filtered') = obj.builder.create_checkbox('Rename all filtered files', ...
                false, 7, [1, 2], 'ValueChangedFcn', @obj.rename_filtered_checkbox_changed);

            %find and replace
            options = {'Regex Find & Replace', 'Add Prefix', 'Add Suffix'};
            obj.widgets('rename_function') = obj.builder.create_dropdown(options, [8 9], [1 2]);
            obj.widgets('find_text') = obj.builder.create_text('Find', 8, 3);
            obj.widgets('find') = obj.builder.create_edit('', 8, 4);
            obj.widgets('replace_text') = obj.builder.create_text('Replace', 9, 3);
            obj.widgets('replace') = obj.builder.create_edit('', 9, 4);
            obj.rename_filtered_checkbox_changed(obj.widgets('rename_filtered'));

            obj.builder.create_button('Run', @obj.run_selected_function, [7 10], 5);
            
            %function dropdown
            options = {'Copy files','Move files','Delete files'};
            obj.widgets('function') = obj.builder.create_dropdown(options, 10, [1 4], ...
                'ValueChangedFcn', @obj.function_dropdown_changed);
            
            uibutton(obj.fig, 'Text', '?', 'ButtonPushedFcn', @obj.display_help_fig, ...
                'Position', [475 460 20 20], 'BackgroundColor', [80 80 255] / 256);
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
                uiwait(warndlg('EI1: An internal error occured while setting gui enables'));
            end
        end

        function rename_filtered_checkbox_changed(obj, widget, ~)
            %Callback for value change of rename_filtered checkbox
            components = {'rename_function', 'find_text', 'find', 'replace_text', 'replace'};
            obj.set_enable(widget.Value, components);
        end
        
        function function_dropdown_changed(obj, widget, ~)
            %Callback for value change of functions dropdown
            components = {'to', 'dest_folder', 'dest_select'};
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
                uiwait(warndlg('EB1: An error occured while selecting the folder'));
            end
        end

        function files = filter_files(obj, varargin)
            %Callback for filter button
            try
                folder = obj.widgets('source_folder').Value;
                filter = obj.widgets('filter').Value;
                files = lib.filter_files(folder, filter);
            catch
                uiwait(warndlg('EB2: An error occured while filtering files'));
            end

            try
                widget = obj.widgets('table');
                widget.Data = files;
            catch
                uiwait(warndlg('EB21: An error occured while adding filtered files to table!'));
            end
        end

        function run_selected_function(obj, varargin)
            %Callback for run_button to run function selected in function select dropdown.
            try
                files_ = obj.filter_files();
                if strcmp('Delete files', obj.widgets('function').Value)
                    lib.delete_files(files);
                else
                    prefix = '';
                    suffix = '';
                    mode = lower(regexp(obj.widgets('function').Value, '\w+?(?=\s)', 'match', 'once'));
                    
                    lib.copy_files(files_, ...
                        'folder', obj.widgets('dest_folder').Value, ...
                        'find', obj.widgets('find').Value, ...
                        'replace', obj.widgets('replace').Value, ...
                        'prefix', prefix, ...
                        'suffix', suffix, ...
                        'regexp', false, ...
                        'mode', mode);
                end
                uiwait(msgbox('Successfully ran the selected function'));
            catch
                uiwait(warndlg('EB3: An error occured while running the selected function'));
            end
        end
    end

    methods(Access = private, Static)
        function display_help_fig(varargin)
            %Callback for help button
            try
                text = help(mfilename('fullpath'));
                fig = uifigure('Name', 'Help', 'Position', [450 100 450 500]);
                uitextarea(fig, 'Value', text, 'Position', [0 0 450 500], ...
                    'BackgroundColor', [200 200 255]/256);
            catch
                uiwait(warndlg('An error occured while displaying the help figure'));
            end
        end
    end
end
