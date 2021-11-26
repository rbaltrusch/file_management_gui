%Given an input filepath, renames that file and returns the new file name.
%
%Optional parameters:
%   find    (char)      string to be matched by a replace function
%   replace (char)      replacement for matched string
%   prefix  (char)      string to be added to start of file name
%   suffix  (char)      string to be added to end of file name
%   regexp  (logical)   turns on regexprep instead of strrep
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function new_filename = rename_file(filepath, varargin)
    args = parse_inputs(varargin{:});
    [~, filename, extension] = fileparts(filepath);

    if args.regexp
        rename = @regexprep;
    else
        rename = @strrep;
    end

    renamed_file = rename(filename, args.find, args.replace);
    new_filename = [args.prefix renamed_file args.suffix extension];
end

function results = parse_inputs(varargin)
    parser = inputParser;
    parser.KeepUnmatched = true;

    addParameter(parser, 'find', '', @ischar);
    addParameter(parser, 'replace', '', @ischar);
    addParameter(parser, 'regexp', false, @islogical);
    addParameter(parser, 'prefix', '', @ischar);
    addParameter(parser, 'suffix', '', @ischar);

    parser.parse(varargin{:});
    results = parser.Results;
end
