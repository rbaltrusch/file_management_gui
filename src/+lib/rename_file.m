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
