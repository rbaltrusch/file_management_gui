%Increments a counter at end of filepath until filepath no longer is a file
%that currently exists, then returns that filepath.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function filepath = rename_conflicting_file(filepath)
    counter = 1;
    [folder, filename, extension] = fileparts(filepath);
    while isfile(filepath)
        new_filename = sprintf('%s%i%s', filename, counter, extension);
        filepath = fullfile(folder, new_filename);
        counter = counter + 1;
    end
end
