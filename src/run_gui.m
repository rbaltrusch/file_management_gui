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
%
%TODO: implement error handling in the update loop
%TODO: add checkbox that enables/disables recursive search of source folder
%
%Author: Richard Baltrusch
%Date: 06/11/2020

function gui()
%% Pre-defining variables
loading_waitbar = waitbar(0,'Loading...');
%loading_waitbar.CloseRequestFcn = @(source,event) 0; %waitbar cant be closed anymore

colour = [150 150 255]/256;
fig_pos = [500 100]; %x, y
fig_size = [500 520]; %x, y

filter = '*';
extension = '.*';
find_expression = '';
replace_expression = '';
rename_pattern = '';
flags = struct;
files = {};
from_folder = pwd;
to_folder = pwd;

%only required for to_folder text area when delete function is selected
to_selected_folder_text_area_value_from_delete = '';

%% GUI Components: Figure and dependant textboxes
%Figure
fig = uifigure('Visible','off');
fig.Name = 'File Management GUI';
fig.Position = [fig_pos fig_size];

%Title textbox
title_text_box = uitextarea(fig);
title_text_box.Value = 'File Management GUI';
title_text_box.Position = [20, fig_size(2)-55, fig_size(1)-40, 40];
title_text_box.BackgroundColor = colour;
title_text_box.FontSize = 25;
title_text_box.FontWeight = 'bold';
title_text_box.HorizontalAlignment = 'center';

%% GUI Components: Buttons
from_folder_button = uibutton(fig);
from_folder_button.Text = 'Select folder';
from_folder_button.BackgroundColor = colour;
from_folder_button.Position = [fig_size(1)-110, fig_size(2)-85, 90, 20];
from_folder_button.ButtonPushedFcn = @(button,event) select_folder(button,fig);

filter_button = uibutton(fig);
filter_button.Text = 'Filter';
filter_button.BackgroundColor = colour;
filter_button.Position = [fig_size(1)-110, fig_size(2)-145, 90, 50];
filter_button.ButtonPushedFcn = @(button,event) filter_files(button,from_folder,extension,filter);

run_button = uibutton(fig);
run_button.Text = 'Run';
run_button.BackgroundColor = colour;
run_button.Position = [fig_size(1)-110, 20, 90, 105];
run_button.ButtonPushedFcn = @(button,event) run_selected_function(files,from_folder,flags,rename_pattern);

to_folder_button = uibutton(fig);
to_folder_button.Text = 'Select folder';
to_folder_button.BackgroundColor = colour;
to_folder_button.Position = [fig_size(1)-110, 135, 90, 20];
to_folder_button.ButtonPushedFcn = @(button,event) select_folder(button,fig);

help_button = uibutton(fig);
help_button.Text = '?';
help_button.BackgroundColor = [80 80 255]/256;
help_button.Position = [fig_size(1)-40, fig_size(2)-35, 20, 20];
help_button.ButtonPushedFcn = @(button,event) display_help_fig();

%% GUI Components: Table
file_table = uitable(fig);
file_table.Position = [20, fig_size(2)-355, fig_size(1)-40, 200];
file_table.CellSelectionCallback = @(table,event) get_selected_files(table,event);

%% GUI Components: Text edits and dependent text displays
from_folder_text_area = uitextarea(fig);
from_folder_text_area.Value = 'From:';
from_folder_text_area.BackgroundColor = colour;
from_folder_text_area.Position = [20, fig_size(2)-85, 45, 20];

from_selected_folder_text_area = uitextarea(fig);
from_selected_folder_text_area.Value = from_folder;
from_selected_folder_text_area.Position = [65, fig_size(2)-85, fig_size(1)-140-45, 20];
selected_folder_text_area_previous_value = from_folder;

extension_text_edit = uieditfield(fig);
extension_text_edit.Value = extension;
extension_text_edit.Position = [round(fig_size(1)-60-90)/2+20, fig_size(2)-115, round(fig_size(1)-40-90)/2, 20];

extension_text_area = uitextarea(fig);
extension_text_area.Value = 'Extension';
extension_text_area.Position = [20, fig_size(2)-115, round(fig_size(1)-60-90)/2, 20]; 
extension_text_area.BackgroundColor = colour;
extension_text_area.Editable = 'off';

filter_text_edit = uieditfield(fig);
filter_text_edit.Value = filter;
filter_text_edit.Position = [round(fig_size(1)-60-90)/2+20, fig_size(2)-145, round(fig_size(1)-40-90)/2, 20];

filter_text_area = uitextarea(fig);
filter_text_area.Value = 'Filter expression';
filter_text_area.Position = [20, fig_size(2)-145, round(fig_size(1)-60-90)/2, 20];
filter_text_area.BackgroundColor = colour;
filter_text_area.Editable = 'off';

to_folder_text_area = uitextarea(fig);
to_folder_text_area.Value = 'To:';
to_folder_text_area.BackgroundColor = colour;
to_folder_text_area.Position = [20, 135, 45, 20];

to_selected_folder_text_area = uitextarea(fig);
to_selected_folder_text_area.Value = to_folder;
to_selected_folder_text_area.Position = [65, 135, fig_size(1)-140-45, 20];
to_selected_folder_text_area_previous_value = to_folder;

find_expression_text_area = uitextarea(fig);
find_expression_text_area.Value = 'Find';
find_expression_text_area.Position = [round(fig_size(1)-60-90)/2+20-3, 90, round(fig_size(1)-40-90)/4, 20];
find_expression_text_area.BackgroundColor = colour;
find_expression_text_area.Editable = 'off';
find_expression_text_area.Enable = 'off';

find_expression_text_edit = uieditfield(fig);
find_expression_text_edit.Value = find_expression;
find_expression_text_edit.Position = [round(fig_size(1)-60-90)/2+20+round(fig_size(1)-40-90)/4-3, 90, round(fig_size(1)-40-90)/4+3, 20];
find_expression_text_edit.Enable = 'off';

replace_expression_text_area = uitextarea(fig);
replace_expression_text_area.Value = 'Replace';
replace_expression_text_area.Position = [round(fig_size(1)-60-90)/2+20-3, 60, round(fig_size(1)-40-90)/4, 20];
replace_expression_text_area.BackgroundColor = colour;
replace_expression_text_area.Editable = 'off';
replace_expression_text_area.Enable = 'off';

replace_expression_text_edit = uieditfield(fig);
replace_expression_text_edit.Value = replace_expression;
replace_expression_text_edit.Position = [round(fig_size(1)-60-90)/2+20+round(fig_size(1)-40-90)/4-3, 60, round(fig_size(1)-40-90)/4+3, 20];
replace_expression_text_edit.Enable = 'off';

%% GUI Components: Dropdowns
function_select_dropdown = uidropdown(fig);
function_select_dropdown.Items = {'Copy files','Move files','Delete files'};
function_select_dropdown.Value = function_select_dropdown.Items{1};
function_select_dropdown.Position = [20 20 round(fig_size(1)-50-90) + 3 30];
function_select_dropdown.BackgroundColor = colour;

rename_function_select_dropdown = uidropdown(fig);
rename_function_select_dropdown.Items = {'Add Prefix', 'Add Suffix', 'Regexp Find and Replace'};
rename_function_select_dropdown.Value = rename_function_select_dropdown.Items{3};
rename_function_select_dropdown.Position = [20, 60, round(fig_size(1)-60-90)/2, 50];
rename_function_select_dropdown.BackgroundColor = colour;
rename_function_select_dropdown.Enable = 'off';

%% GUI Components: Checkboxes
rename_on_conflict_checkbox = uicheckbox(fig);
rename_on_conflict_checkbox.Text = 'Rename duplicate files';
rename_on_conflict_checkbox.Value = 1;
rename_on_conflict_checkbox.Position = [20 + round(fig_size(1)-60-90)/2, 110, round(fig_size(1)-60-90)/2 - 30, 20];

rename_checkbox = uicheckbox(fig);
rename_checkbox.Text = 'Rename all filtered files';
rename_checkbox.Value = 0;
rename_checkbox.Position = [20, 110, round(fig_size(1)-60-90)/2, 20];

%% Wrap up init
%Update loading waitbar, then delete it
waitbar(1,loading_waitbar,'Loading...');
delete(loading_waitbar);
fig.Visible = 'on';

%% GUI property and value updates during user interaction
while isvalid(fig)
    %% Update variables
    
    %Update checkbox and text edit values
    filter = filter_text_edit.Value;
    extension = extension_text_edit.Value;
    flags.rename = rename_checkbox.Value;
    flags.rename_on_conflict = rename_on_conflict_checkbox.Value;
    
    %Update from_folder from button
    if ~isempty(from_folder_button.UserData)
        selected_folder_text_area_previous_value = from_folder;
        from_folder = from_folder_button.UserData;
        from_folder_button.UserData = '';
    end
    
    %Update to_folder from button
    if ~isempty(to_folder_button.UserData)
        to_selected_folder_text_area_previous_value = to_folder;
        to_folder = to_folder_button.UserData;
        to_folder_button.UserData = '';
    end
    
    %Update from_folder from text area value
    if ~strcmp(selected_folder_text_area_previous_value,from_selected_folder_text_area.Value)
        selected_folder_text_area_previous_value = from_folder;
        from_folder = from_selected_folder_text_area.Value{1};
    else
        from_selected_folder_text_area.Value = from_folder;
    end
    
    %Update to_folder from text area value
    if ~strcmp(to_selected_folder_text_area_previous_value,to_selected_folder_text_area.Value)
        to_selected_folder_text_area_previous_value = to_folder;
        to_folder = to_selected_folder_text_area.Value{1};
    else
        to_selected_folder_text_area.Value = to_folder;
    end
    
    %Update table data with file data from filter button
    if ~isempty(filter_button.UserData)
        files = filter_button.UserData;
        filter_button.UserData = {};
        file_table.Data = files;
    end
    
    %Update rename pattern from dropdown and text edit values
    switch(rename_function_select_dropdown.Value)
        case 'Add Prefix'
            prefix = find_expression_text_edit.Value;
            rename_pattern = ['prefix:' prefix];
        case 'Add Suffix'
            suffix = find_expression_text_edit.Value;
            rename_pattern = ['suffix:' suffix];
        case 'Regexp Find and Replace'
            find = find_expression_text_edit.Value;
            replace = replace_expression_text_edit.Value;
            rename_pattern = ['regexp:' find ':' replace];
    end
    
    %Update move and delete flags from dropdown value
    switch(function_select_dropdown.Value)
        case 'Copy files'
            flags.move = false;
            flags.delete = false;
        case 'Move files'
            flags.move = true;
            flags.delete = false;
        case 'Delete files'
            flags.move = false;
            flags.delete = true;
    end
    
    %% Handling variable GUI layout

    %Handle find and replace text boxes depending on rename function chosen
    if contains(rename_pattern,'regexp')
        find_expression_text_area.Value = 'Find';
        replace_expression_text_area.Visible = 'on';
        replace_expression_text_edit.Visible = 'on';
        replace_expression_text_edit.Editable = 'on';
    else
        if contains(rename_pattern,'prefix')
            find_expression_text_area.Value = 'Prefix';
        else
            find_expression_text_area.Value = 'Suffix';
        end
        replace_expression_text_edit.Visible = 'off';
        replace_expression_text_edit.Editable = 'off';
        replace_expression_text_area.Visible = 'off';
    end
    
    %Disable certain unrequired GUI functions when rename checkbox is ticked
    if flags.rename
        replace_expression_text_area.Enable = 'on';
        replace_expression_text_edit.Enable = 'on';
        find_expression_text_area.Enable = 'on';
        find_expression_text_edit.Enable = 'on';
        rename_function_select_dropdown.Enable = 'on';
    else
        replace_expression_text_area.Enable = 'off';
        replace_expression_text_edit.Enable = 'off';
        find_expression_text_area.Enable = 'off';
        find_expression_text_edit.Enable = 'off';
        rename_function_select_dropdown.Enable = 'off';
    end
    
    %Disable certain unrequired GUI functions when chosen function is deleting
    if flags.delete
        to_folder_text_area.Enable = 'off';
        to_selected_folder_text_area.Enable = 'off';
        to_folder_button.Enable = 'off';
        if isempty(to_selected_folder_text_area_value_from_delete)
            to_selected_folder_text_area_value_from_delete = to_folder;
        end
        to_folder = 'RecycleBin';
        to_selected_folder_text_area.Value = to_folder;
    else
        to_folder_text_area.Enable = 'on';
        to_selected_folder_text_area.Enable = 'on';
        to_folder_button.Enable = 'on';
        if ~isempty(to_selected_folder_text_area_value_from_delete)
            to_folder = to_selected_folder_text_area_value_from_delete;
            to_selected_folder_text_area_previous_value = to_folder;
            to_selected_folder_text_area.Value = to_selected_folder_text_area_value_from_delete;
        else
            to_selected_folder_text_area.Value = to_folder;
        end
    end
    
    %% Refresh button callbacks
    %Since anonymous functions/callbacks snapshot the state of variables
    %passed to them at the time of their definition, we have to refresh the
    %definition of the anonymous function each cycle to capture any changes
    %in the variables passed to them.
    filter_button.ButtonPushedFcn = @(button,event) filter_files(button,from_folder,extension,filter);
    run_button.ButtonPushedFcn = @(button,event) run_selected_function(from_folder,extension,filter,to_folder,flags,rename_pattern);
    to_folder_button.ButtonPushedFcn = @(button,event) select_folder(button,fig);
    from_folder_button.ButtonPushedFcn = @(button,event) select_folder(button,fig);
    
    %% Update the GUI
    drawnow;
    pause(0.02); %limit the rate of gui drawing
end

end

%% Callback functions

function select_folder(button,fig)
    %Callback for select folder buttons
    try
        folder = uigetdir();
        if folder == 0
            folder = '';
        end
        button.UserData = folder;
        figure(fig);
    catch
        uiwait(warndlg('EB1: An error occured while selecting the folder'));
    end
end

function filter_files(button,folderpath,extension,filter)
    %Callback for filter button
    try
        files = lib.get_all_files_with_extension(folderpath, extension, filter);
        button.UserData = files;
    catch
        uiwait(warndlg('EB2: An error occured while filtering files'));
    end
end

function get_selected_files(table,event)
    %Callback for uitable to get selected files and store them in UserData
    try
        indices = event.Indices;
        files = cell(size(indices,1),1);
        for c = 1:size(indices,1)
            files{c} = table.Data{indices(c,1), indices(c,2)};
        end
        table.UserData = strjoin(files,';');
    catch
        uiwait(warndlg('ET1: An error occured while getting selected files from table'));
    end
end

function run_selected_function(from_folder,extension,filter,to_folder,flags,rename_pattern)
    %Callback for run_button to run function selected in function select
    %dropdown.
    try
        files = lib.get_all_files_with_extension(from_folder, extension, filter);
        lib.copy_files_to_folder(files,to_folder,flags,rename_pattern);
        uiwait(msgbox('Successfully ran the selected function'));
    catch
        uiwait(warndlg('EB3: An error occured while running the selected function'));
    end
end

function display_help_fig()
    %Callback for help button
    try
        fig_pos = [450 100]; %x, y
        fig_size = [450 500]; %x, y

        %Help figure
        fig = uifigure('Visible','off');
        fig.Name = 'Help';
        fig.Position = [fig_pos fig_size];

        %Help text, directly read in from the script docu
        text_area = uitextarea(fig);
        text_area.Value = help(mfilename('fullpath'));
        text_area.Position = [0 0 fig_size];
        text_area.BackgroundColor = [200 200 255]/256;

        fig.Visible = 'on';
    catch
        uiwait(warndlg('An error occured while displaying the help figure'));
    end
end
