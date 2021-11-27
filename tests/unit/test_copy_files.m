%Tests src/lib.copy_files function.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_copy_files
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

function test_no_files_no_folder(test_case)
    import matlab.unittest.constraints.IsTrue
    try
        lib.copy_files({});
        passed = true;
    catch
        passed = false;
    end
    verifyThat(test_case, passed, IsTrue);
end

function test_no_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    cd(test_case.TestData.test_subfolder)
    files = lib.filter_files('.');
    lib.copy_files(files);

    files = lib.filter_files('.');
    constraint = IsEqualTo(test_case.TestData.test_subfolder_length * 2); %doubled files
    verifyThat(test_case, length(files), constraint);
end

function test_copy_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_subfolder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_subfolder, 'filter', '*.txt');
    lib.copy_files(files, 'folder', new_folder);

    files = lib.filter_files(new_folder);
    constraint = IsEqualTo(test_case.TestData.test_subfolder_length);
    verifyThat(test_case, length(files), constraint);
end

function test_move_no_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    cd(test_case.TestData.test_subfolder)
    files = lib.filter_files('.', 'filter', '*.txt');
    lib.copy_files(files, 'mode', 'move');

    files = lib.filter_files('.');
    constraint = IsEqualTo(test_case.TestData.test_subfolder_length);
    verifyThat(test_case, length(files), constraint);
end

function test_move_to_folder(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_folder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*.txt');
    lib.copy_files(files, 'folder', new_folder, 'mode', 'move');

    files = lib.filter_files(new_folder);
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_no_rename_conflicting(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_folder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*.txt');
    lib.copy_files(files, 'folder', new_folder, 'rename_conflicting', false);

    files = lib.filter_files(new_folder);
    file_length = test_case.TestData.test_folder_total_length - 2; %two conflicting file not renamed
    verifyThat(test_case, length(files), IsEqualTo(file_length));
end

function test_rename(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_folder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*.txt');
    lib.copy_files(files, 'folder', new_folder, 'rename_conflicting', true, ...
        'find', 't', 'replace', 'f', 'prefix', 'a', 'suffix', 'd');

    files = lib.filter_files(new_folder);
    constraint = IsEqualTo(test_case.TestData.test_folder_total_length);
    verifyThat(test_case, length(files), constraint);
end

function test_rename_no_rename_conflicting(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_folder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*.txt');
    lib.copy_files(files, 'folder', new_folder, 'rename_conflicting', false, ...
        'find', '.+', 'replace', 'x', 'regexp', true);

    files = lib.filter_files(new_folder);
    file_length = 1; %all files renamed to x.txt
    verifyThat(test_case, length(files), IsEqualTo(file_length));
end

function test_no_recursive(test_case)
    import matlab.unittest.constraints.IsEqualTo
    new_folder = fullfile(test_case.TestData.test_folder, '_testfiles3');
    assert(~isfolder(new_folder));

    files = lib.filter_files(test_case.TestData.test_folder, 'filter', '*.txt', 'recursive', false);
    lib.copy_files(files, 'folder', new_folder);

    files = lib.filter_files(new_folder);
    constraint = IsEqualTo(test_case.TestData.test_folder_length);
    verifyThat(test_case, length(files), constraint);
end
