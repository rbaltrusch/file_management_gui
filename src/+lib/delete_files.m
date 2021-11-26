%Sends all specified files to the recycle bin.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function delete_files(files)
    %all deleted files go to recycle bin instead of being permanently deleted
    recycle on
    for c = 1:length(files)
        delete(files{c});
    end
end
