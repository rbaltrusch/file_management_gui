%Tests src/lib.filter_files function.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_filter_files
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

function test_cell(test_case)
    import matlab.unittest.constraints.IsTrue
    files = lib.filter_files(test_case.TestData.test_folder);
    verifyThat(test_case, iscell(files), IsTrue);
end

function test_current_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    cd(test_case.TestData.test_folder);
    files = lib.filter_files('.');
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_parent_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    cd(test_case.TestData.test_subfolder);
    files = lib.filter_files('..');
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_absolute_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    folder = fullfile(fileparts(mfilename('fullpath')), test_case.TestData.test_folder);
    files = lib.filter_files(folder);
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_filter(test_case)
    import matlab.unittest.constraints.IsEqualTo
    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*test2*');
    verifyThat(test_case, length(files), IsEqualTo(2));
end

function test_non_existing_folder(test_case)
    import matlab.unittest.constraints.IsEmpty
    files = lib.filter_files(test_case.TestData.non_existing_folder);
    verifyThat(test_case, files, IsEmpty);
end

function test_duplicate_call(test_case)
    import matlab.unittest.constraints.IsEqualTo
    lib.filter_files(test_case.TestData.test_folder);
    files = lib.filter_files(test_case.TestData.test_folder);
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_recursive_search_on(test_case)
    import matlab.unittest.constraints.IsEqualTo
    files = lib.filter_files(test_case.TestData.test_folder, 'recursive', true);
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_recursive_search_off(test_case)
    import matlab.unittest.constraints.IsEqualTo
    files = lib.filter_files(test_case.TestData.test_folder, 'recursive', false);
    constraint = IsEqualTo(test_case.TestData.test_folder_length);
    verifyThat(test_case, length(files), constraint);
end
