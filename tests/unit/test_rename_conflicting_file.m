%Tests src/lib.rename_conflicting_file function.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_rename_conflicting_file
tests = functiontests(localfunctions);
end

function setupOnce(test_case)
    %runs only once before all the tests in this file are run
    test_case.TestData.orig_folder = pwd;
    test_case.TestData.test_folder = '_testfiles_';

    %add functions under test to path
    addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src')));
end

function setup(test_case)
    %runs before every test case
    cd(fileparts(mfilename('fullpath')));
    folder = test_case.TestData.test_folder;
    mkdir(folder);
    fclose(fopen(fullfile(folder, 'test.txt'), 'w'));
    fclose(fopen(fullfile(folder, 'test2.txt'), 'w'));
end

function teardown(test_case)
    %runs after every test case
    cd(test_case.TestData.orig_folder);
    rmdir(test_case.TestData.test_folder, 's');
end

function test_not_existing_file(test_case)
    import matlab.unittest.constraints.IsTrue
    filepath = fullfile(test_case.TestData.test_folder, 'notexisting.txt');
    new_filepath = lib.rename_conflicting_file(filepath);
    condition = ischar(new_filepath) && strcmp(new_filepath, filepath);
    verifyThat(test_case, condition, IsTrue);
end

function test_existing_file(test_case)
    import matlab.unittest.constraints.IsTrue
    filepath = fullfile(test_case.TestData.test_folder, 'test.txt');
    new_filepath = lib.rename_conflicting_file(filepath);
    expected_filepath = fullfile(test_case.TestData.test_folder, 'test1.txt');
    condition = strcmp(new_filepath, expected_filepath);
    verifyThat(test_case, condition, IsTrue);
end

function test_folder(test_case)
    import matlab.unittest.constraints.IsTrue
    %does not rename folders
    new_filepath = lib.rename_conflicting_file(test_case.TestData.test_folder);
    condition = strcmp(new_filepath, test_case.TestData.test_folder);
    verifyThat(test_case, condition, IsTrue);
end

function test_dot_in_filename(test_case)
    import matlab.unittest.constraints.IsTrue
    filename = 'test.something.txt';
    filepath = fullfile(test_case.TestData.test_folder, filename);
    new_filepath = lib.rename_conflicting_file(filepath);
    condition = strcmp(new_filepath, filepath);
    verifyThat(test_case, condition, IsTrue);
end

function test_double_call(test_case)
    import matlab.unittest.constraints.IsTrue
    filepath = fullfile(test_case.TestData.test_folder, 'test.txt');
    lib.rename_conflicting_file(filepath);
    new_filepath = lib.rename_conflicting_file(filepath);
    expected_filepath = fullfile(test_case.TestData.test_folder, 'test1.txt');
    condition = strcmp(new_filepath, expected_filepath);
    verifyThat(test_case, condition, IsTrue);
end
