%Runs the built in MATLAB linter on all m-files in the repository (using checkcode).
%
%Author: Richard Baltrusch
%Date: 18/12/2021

function lint_files()
    source_folder = fullfile(fileparts(mfilename('fullpath')), '..');
    contents = dir(fullfile(source_folder, '**/*.m'));
    files = {};
    for c = 1:length(contents)
        files{end + 1, 1} = fullfile(contents(c).folder, contents(c).name); %#ok<AGROW>
    end

    results = checkcode(files);
    if ~all(cellfun(@isempty, results))
        for c = 1:length(results)
            if ~isempty(results{c})
                for k = 1:length(results{c})
                    disp(results{c}(k));
                end
            end
        end
        error('Lint messages exist!');
    else
        disp('No errors found!');
    end
end
