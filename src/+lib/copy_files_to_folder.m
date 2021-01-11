% This function copies the files specified (cell) to a given folder
%
%TODO: Not ideal: copy, move and delete flags should be combined into one
%to be less cumbersome.
%
%Author: Richard Baltrusch
%Date: 06/11/2020

function copy_files_to_folder(files,folder,flags,varargin)
    %% Handle default parameterization if flags is not passed in
    
    default_flags.move = false;
    default_flags.rename_on_conflict = true;
    default_flags.rename = false;
    default_flags.delete = false;
        
    if nargin < 3
        flags = default_flags;
        if nargin == 1
            folder = pwd;
        end
    else
        %add any fields that might have been left out by the flags struct
        %passed in and assign default values to them
        default_fields = fieldnames(default_flags);
        passed_fields = fieldnames(flags);
        fields = setdiff(default_fields, passed_fields);
        for c = 1:length(fields)
            flags.(fields{c}) = default_flags.(fields{c});
        end
    end
    
    %% Handle optional arguments
    if flags.rename
        if isempty(varargin)
            error('Please specify a rename pattern when setting flags.rename')
        else
            rename_pattern = varargin{1};
        end
    end
    
    %% Other preliminaries
    % Get move_function
    delete_flag = false;
    if flags.move
        move_function = @(filepath_old, filepath_new) movefile(filepath_old, filepath_new);
    elseif flags.delete
        %Switch on recycle means that all deleted files go to recycle bin
        %instead of being permanently deleted
        recycle on
        move_function = @(filepath_old,~) delete(filepath_old);
        delete_flag = true;
    else
        %default to just copying a file from one dir to another
        move_function = @(filepath_old, filepath_new) copyfile(filepath_old, filepath_new);
    end
    
    %Handle folder specified
    if ~isfolder(folder) && ~delete_flag
        %Make specified folder if it doesnt exist yet
        mkdir(folder);
    else
        %remove any files already contained in folder, to avoid copying all
        %the files it might already contain into itself again
        for c = length(files):-1:1
            folderpath = fileparts(files{c});
            abs_folder = get_abs_folder(folder);
            if strcmp(folderpath,abs_folder)
                files(c,:) = [];
            end
        end
    end
    
    %% Work on files
    for c = 1:length(files)
        [~,filename,extension] = fileparts(files{c});
        
        if flags.rename
            filename = rename_filename(filename, rename_pattern);
        end
        
        new_filepath = fullfile(folder,[filename,extension]);
        
        if flags.rename_on_conflict && isfile(new_filepath)
            new_filepath = rename_conflicting_file(new_filepath);
        end
        
        move_function(files{c},new_filepath);
    end
end

function filename = rename_filename(filename, rename_pattern)
    %To be implemented
    [rename_option, expression] = split_rename_pattern(rename_pattern);
    switch(rename_option)
        case 'prefix'
            prefix = get_prefix(expression);
            filename = [prefix filename];
        case 'suffix'
            suffix = get_suffix(expression);
            filename = [filename suffix];
        case 'regexp'
            [find_expression, replace_expression] = split_regexp_expression(expression);
            filename = regexprep(filename,find_expression,replace_expression);
    end
end

function [rename_option, expression] = split_rename_pattern(rename_pattern)
    %Helper function used in rename_filename
    split_rename_pattern = strsplit(rename_pattern,':');
    if length(split_rename_pattern) >= 2
        rename_option = split_rename_pattern{1};
        expression = strjoin(split_rename_pattern(2:end),':');
    else
        rename_option = '';
        expression = '';
        warning(['Could not determine rename option and expression for string ' rename_pattern]);
    end
end

function [find_expression, replace_expression] = split_regexp_expression(expression)
    %Helper function used in rename_filename
    split_expression = strsplit(expression,':');
    if length(split_expression) == 2
        find_expression = split_expression{1};
        replace_expression = split_expression{2};
    else
        find_expression = '';
        replace_expression = '';
        warning(['Could not determine find and replace expressions for string ' expression]);
    end
end

function prefix = get_prefix(expression)
    %Helper function used in rename_filename
    split_expression = strsplit(expression,':');
    prefix = split_expression{1};
end

function suffix = get_suffix(expression)
%Helper function used in rename_filename
    split_expression = strsplit(expression,':');
    suffix = split_expression{1};
end

function new_filepath = rename_conflicting_file(new_filepath)
    counter = 1;
    [folder,filename,extension] = fileparts(new_filepath);
    while isfile(new_filepath)
        new_filename = [filename num2str(counter) extension];
        new_filepath = fullfile(folder,new_filename);
        counter = counter + 1;
    end
end

function abs_folder = get_abs_folder(folder)
    contents = dir(fullfile(folder,'..',['*' folder]));
    if ~isempty(contents)
        abs_folder = fullfile(contents(1).folder,contents(1).name);
    else
        abs_folder = '';
        warning('Could not find folder and determine absolute path');
    end
end