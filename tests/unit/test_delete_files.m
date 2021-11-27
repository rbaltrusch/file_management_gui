%Tests src/lib.delete_files function.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_delete_files
tests = functiontests(localfunctions);
end

function setupOnce(test_case)
    %runs only once before all the tests in this file are run
    test_case.TestData.orig_folder = pwd;
    test_case.TestData.test_folder = '_testfiles_';
    test_case.TestData.test_subfolder = fullfile(test_case.TestData.test_folder, '_testfiles2_');
    test_case.TestData.non_existing_folder = '_testnotexisting_';

    %add functions under test to path
    addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src')));
end

function setup(test_case)
    %runs before every test case
    cd(fileparts(mfilename('fullpath')));

    folder = test_case.TestData.test_folder;
    mkdir(folder);
    fclose(fopen(fullfile(folder, 'test1.txt'), 'w'));
    fclose(fopen(fullfile(folder, 'test2.txt'), 'w'));
    fclose(fopen(fullfile(folder, 'test3.txt'), 'w'));
    test_case.TestData.test_folder_length = 3;

    folder = test_case.TestData.test_subfolder;
    mkdir(folder);
    fclose(fopen(fullfile(folder, 'test2.txt'), 'w'));
    fclose(fopen(fullfile(folder, 'test3.txt'), 'w'));
    test_case.TestData.test_subfolder_length = 2;
    test_case.TestData.test_folder_total_length = 5;
end

function teardown(test_case)
    %runs after every test case
    cd(test_case.TestData.orig_folder);
    rmdir(test_case.TestData.test_folder, 's');
end

function test_folder_exists(test_case)
    import matlab.unittest.constraints.IsFolder
    files = lib.filter_files(test_case.TestData.test_folder);
    lib.delete_files(files);
    verifyThat(test_case, test_case.TestData.test_folder, IsFolder);
end

function test_files_deleted(test_case)
    import matlab.unittest.constraints.IsEmpty
    files = lib.filter_files(test_case.TestData.test_folder, 'recursive', true);
    lib.delete_files(files);
    verifyThat(test_case, files(isfile(files)), IsEmpty);
end

function test_not_files_deleted(test_case)
    import matlab.unittest.constraints.IsEqualTo
    files = lib.filter_files(test_case.TestData.test_folder, 'recursive', false);
    lib.delete_files(files);

    files = lib.filter_files(test_case.TestData.test_folder, 'recursive', true);
    constraint = IsEqualTo(test_case.TestData.test_subfolder_length);
    verifyThat(test_case, length(files), constraint);
end
