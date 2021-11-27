%Tests src/lib.rename_file function.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_rename_file
tests = functiontests(localfunctions);
end

function test_bare_rename(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt');
    verifyThat(test_case, filename, IsEqualTo('file.txt'));
end

function test_bare_filepath(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file(fullfile('test', 'file.txt'));
    verifyThat(test_case, filename, IsEqualTo('file.txt'));
end

function test_normal_find(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'find', 'f');
    verifyThat(test_case, filename, IsEqualTo('ile.txt'));
end

function test_normal_replace(test_case)
    %finds nothing so replaces nothing
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'replace', 'f');
    verifyThat(test_case, filename, IsEqualTo('file.txt'));
end

function test_normal_find_replace(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'find', 'f', 'replace', 'g');
    verifyThat(test_case, filename, IsEqualTo('gile.txt'));
end

function test_regexp_find(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('filee0.txt', 'find', '[ie]+(?!\d)', 'regexp', true);
    verifyThat(test_case, filename, IsEqualTo('fle0.txt'));
end

function test_regexp_replace(test_case)
    %finds nothing so replaces nothing
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'replace', 'er', 'regexp', true);
    verifyThat(test_case, filename, IsEqualTo('file.txt'));
end

function test_regexp_find_replace(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('filee0.txt', 'find', '[ie]+(?!\d)', 'replace', 'o', 'regexp', true);
    verifyThat(test_case, filename, IsEqualTo('foloe0.txt'));
end

function test_prefix(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'prefix', 'test_');
    verifyThat(test_case, filename, IsEqualTo('test_file.txt'));
end

function test_suffix(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'suffix', '_01');
    verifyThat(test_case, filename, IsEqualTo('file_01.txt'));
end

function test_prefix_suffix(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'prefix', 'test_', 'suffix', '_01');
    verifyThat(test_case, filename, IsEqualTo('test_file_01.txt'));
end

function test_normal_combined(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('file.txt', 'find', 'f', 'replace', 'gg', ...
        'prefix', 'test_', 'suffix', '_01');
    verifyThat(test_case, filename, IsEqualTo('test_ggile_01.txt'));
end

function test_regexp_combined(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filename = lib.rename_file('fiile.txt', 'find', 'i(?=l)', 'replace', 'l', ...
        'regexp', true, 'prefix', 'test_', 'suffix', '_01');
    verifyThat(test_case, filename, IsEqualTo('test_fille_01.txt'));
end

function test_filepath_combined(test_case)
    import matlab.unittest.constraints.IsEqualTo
    filepath = fullfile('testfolder', 'fiile.txt');
    filename = lib.rename_file(filepath, 'find', 'i(?=l)', 'replace', 'l', ...
        'regexp', true, 'prefix', 'test_', 'suffix', '_01');
    verifyThat(test_case, filename, IsEqualTo('test_fille_01.txt'));
end
