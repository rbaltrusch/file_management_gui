% This function copies the files specified (cell) to a given folder
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function copy_files(files, varargin)
    args = parse_inputs(files, varargin{:});

    if ~isempty(args.folder) && ~isfolder(args.folder)
        mkdir(args.folder);
    end

    for c = 1:length(files)
        new_filename = lib.rename_file(files{c}, varargin{:});
        new_filepath = fullfile(args.folder, new_filename);
        if args.rename_conflicting
            new_filepath = lib.rename_conflicting_file(new_filepath);
        end

        try
            args.move_function(files{c}, new_filepath);
        catch
            warning('Failed to execute file mode %s for file %s!', args.mode, files{c});
        end
    end
end

function results = parse_inputs(varargin)
    parser = inputParser;
    parser.KeepUnmatched = true;

    addRequired(parser, 'files', @iscell);
    addParameter(parser, 'folder', pwd, @ischar);
    addParameter(parser, 'mode', 'copy', @(x) any(strcmp(x, {'copy', 'move'})));
    addParameter(parser, 'rename_conflicting', true, @islogical);
    parser.parse(varargin{:});
    results = parser.Results;

    if strcmp(results.mode, 'copy')
        results.move_function = @(file, filepath) copyfile(file, filepath);
    else
        results.move_function = @(file, filepath) movefile(file, filepath);
    end
end
