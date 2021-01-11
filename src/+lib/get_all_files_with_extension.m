%Finds all files in the given folder with the passed extension and
%containing the filter passed in.
%
%FIXME: Filter does not work if extension is passed as default (.*), (this
%is consistent with Windows Explorer functionality).
%
%Author: Richard Baltrusch
%Date: 06/11/2020

function files = get_all_files_with_extension(folderpath, extension, filter)
    paths = get_all_folders(folderpath);
    full_extension_filter = get_full_extension_filter(extension, filter);
    
    files = {};
    for c = 1:length(paths)
        contents = dir(fullfile(paths{c},full_extension_filter));
        for k = 1:length(contents)
            if ~contents(k).isdir
                full_filepath = fullfile(contents(k).folder,contents(k).name);
                files{length(files)+1, 1} = full_filepath;
            end
        end
    end
end

function full_extension_filter = get_full_extension_filter(extension, filter)
    %Returns a filter for the extension, to be used in a dir expression
    
    %filter for extension dot, and remove any other non ASCII chars from
    %extension.
    extension_without_dot = regexp(extension,'(?(?<=\.)\w+|\w+)','match','once');
    if isempty(extension_without_dot)
        extension_without_dot = '*';
    end
    
    %process filter to avoid double asterixes
    filter = strrep(filter,'*','');
    
    full_extension_filter = [ '*' filter '*.' extension_without_dot];
    full_extension_filter = strrep(full_extension_filter,'**','*');
end

function paths = get_all_folders(folderpath)
    %returns a cell array of all directories found in folderpath,
    %recursively
    paths_string = genpath(folderpath);
    paths = strsplit(paths_string,';');
    
    %remove the final path to avoid having current directory twice
    if ~isempty(paths)
        paths(end) = [];
    end
end
