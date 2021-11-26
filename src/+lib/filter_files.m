%Finds all files in the given folder with the passed extension and
%containing the filter passed in.
%
%Optional parameters:
%   filter    (char)      globbing pattern to filter strings
%   recursive (logical)   flag to turn on recursive matching (default true)
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function files = filter_files(folderpath, varargin)
    args = parse_inputs(varargin{:});
    full_filter = sprintf('%s', args.folder_filter, args.filter);
    contents = dir(fullfile(folderpath, full_filter));
    filtered_contents = contents([contents(:).isdir] == 0);
    files = cell(length(filtered_contents), 1);
    for c = 1:length(filtered_contents)
        files{c} = fullfile(filtered_contents(c).folder, filtered_contents(c).name);
    end
end

function results = parse_inputs(varargin)
    parser = inputParser;
    parser.KeepUnmatched = true;

    addParameter(parser, 'filter', '', @ischar);
    addParameter(parser, 'recursive', true, @islogical);

    parser.parse(varargin{:});
    results = parser.Results;

    if results.recursive
        results.folder_filter = '**/';
    else
        results.folder_filter = '';
    end
end
