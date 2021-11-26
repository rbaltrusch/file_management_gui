%Finds all files in the given folder with the passed extension and
%containing the filter passed in.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function files = filter_files(folderpath, filter)
    full_filter = sprintf('**/%s', filter);
    contents = dir(fullfile(folderpath, full_filter));
    filtered_contents = contents([contents(:).isdir] == 0);
    files = cell(length(filtered_contents), 1);
    for c = 1:length(filtered_contents)
        files{c} = fullfile(filtered_contents(c).folder, filtered_contents(c).name);
    end
end
