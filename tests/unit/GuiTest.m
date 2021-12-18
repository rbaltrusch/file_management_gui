classdef GuiTest < matlab.uitest.TestCase
    properties
        orig_folder char
        test_folder char = '_testfiles_'
        destination_folder char = '_testfiles3_'
        test_subfolder char
        non_existing_folder char = '_testnotexisting_'
        test_folder_length double
        test_subfolder_length double
        test_folder_total_length double
        gui %gui.Gui
    end

    methods(TestClassSetup)
        function setup_class(test_case)
            %runs only once before all the tests in this file are run
            test_case.orig_folder = pwd;
            test_case.test_subfolder = fullfile(test_case.test_folder, '_testfiles2_');
            addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src')));
        end
    end

    methods(TestMethodSetup)
        function setup_method(test_case)
            %runs before every test case
            cd(fileparts(mfilename('fullpath')));

            folder = test_case.test_folder;
            mkdir(folder);
            fclose(fopen(fullfile(folder, 'test1.txt'), 'w'));
            fclose(fopen(fullfile(folder, 'test2.txt'), 'w'));
            fclose(fopen(fullfile(folder, 'test3.txt'), 'w'));
            test_case.test_folder_length = 3;

            folder = test_case.test_subfolder;
            mkdir(folder);
            fclose(fopen(fullfile(folder, 'test2.txt'), 'w'));
            fclose(fopen(fullfile(folder, 'test3.txt'), 'w'));
            test_case.test_subfolder_length = 2;
            test_case.test_folder_total_length = 5;

            if isfolder(test_case.destination_folder)
                rmdir(test_case.destination_folder, 's');
            end

            %setup gui
            colour = [150 150 255] / 256;
            builder = gui.Builder(colour); %#ok<*PROP>
            test_case.gui = gui.Gui(builder, 'confirm', false);
            test_case.gui.build();

            widget = test_case.gui.widgets('source_folder');
            widget.Value = test_case.test_folder;

            widget = test_case.gui.widgets('dest_folder');
            widget.Value = test_case.destination_folder;
            widget.ValueChangedFcn(widget, 0);

            %Disable test if no display is available (e.g. on CI/CD machine)
            try
                %pressing the filter button has no effect
                press(test_case, test_case.gui.widgets('filter_btn'))
            catch ME
                if strcmp(ME.identifier,'MATLAB:uiautomation:Driver:NoDisplay')
                    test_case.assumeTrue(false, 'Test skipped on display-less machines');
                end
            end
        end
    end

    
    methods(TestMethodTeardown)
        function teardown(test_case)
            %runs after every test case
            rmdir(test_case.test_folder, 's');
            cd(test_case.orig_folder);
            close(test_case.gui.fig);
            if isfolder(test_case.destination_folder)
                rmdir(test_case.destination_folder, 's');
            end
        end
    end

    methods (Test)
        function test_filter(test_case)
            press(test_case, test_case.gui.widgets('filter_btn'));
            test_case.verifyEqual(length(test_case.gui.widgets('table').Data), test_case.test_folder_total_length);
        end

        function test_no_recursive_filter(test_case)
            widget = test_case.gui.widgets('recursive');
            widget.Value = false;

            press(test_case, test_case.gui.widgets('filter_btn'));
            test_case.verifyEqual(length(test_case.gui.widgets('table').Data), test_case.test_folder_length);
        end

        function test_run(test_case)
            press(test_case, test_case.gui.widgets('run_btn'));
            files = lib.filter_files(test_case.destination_folder);
            test_case.verifyEqual(length(files), test_case.test_folder_total_length);
        end

        function test_move(test_case)
            test_case.choose(test_case.gui.widgets('function'), 'Move files');
            press(test_case, test_case.gui.widgets('run_btn'));

            files = lib.filter_files(test_case.destination_folder);
            test_case.verifyEqual(length(files), test_case.test_folder_total_length);

            files = lib.filter_files(test_case.test_folder);
            test_case.verifyEqual(length(files), 0);
        end

        function test_delete(test_case)
            import matlab.unittest.constraints.IsFolder

            test_case.choose(test_case.gui.widgets('function'), 'Delete files');
            press(test_case, test_case.gui.widgets('run_btn'));

            files = lib.filter_files(test_case.test_folder);
            test_case.verifyEqual(length(files), 0);
            test_case.verifyThat(test_case.test_folder, IsFolder);
        end

        function test_no_rename_duplicate(test_case)
            widget = test_case.gui.widgets('rename_duplicate');
            widget.Value = false;
            press(test_case, test_case.gui.widgets('run_btn'));
            files = lib.filter_files(test_case.destination_folder);
            test_case.verifyEqual(length(files), 3); %2 identical files overwritten
        end

        function test_normal_rename(test_case)
            widget = test_case.gui.widgets('find');
            widget.Value = 't';

            widget = test_case.gui.widgets('replace');
            widget.Value = 'f';

            press(test_case, test_case.gui.widgets('run_btn'));
            files = lib.filter_files(test_case.destination_folder, 'filter', '**/fesf*.txt');
            test_case.verifyEqual(length(files), test_case.test_folder_total_length);
        end

        function test_regexp_rename(test_case)
            widget = test_case.gui.widgets('find');
            widget.Value = '^t';

            widget = test_case.gui.widgets('replace');
            widget.Value = 'f';

            widget = test_case.gui.widgets('regexp');
            widget.Value = true;

            press(test_case, test_case.gui.widgets('run_btn'));
            files = lib.filter_files(test_case.destination_folder, 'filter', '**/fest*.txt');
            test_case.verifyEqual(length(files), test_case.test_folder_total_length);
        end

        function test_full_rename(test_case)
            widget = test_case.gui.widgets('find');
            widget.Value = '^t';

            widget = test_case.gui.widgets('replace');
            widget.Value = 'f';

            widget = test_case.gui.widgets('prefix');
            widget.Value = 'pre';

            widget = test_case.gui.widgets('suffix');
            widget.Value = 'suf';

            widget = test_case.gui.widgets('regexp');
            widget.Value = true;

            press(test_case, test_case.gui.widgets('run_btn'));
            files = lib.filter_files(test_case.destination_folder, 'filter', '**/prefest*suf*.txt');
            test_case.verifyEqual(length(files), test_case.test_folder_total_length);
        end

        function test_recycle_bin(test_case)
            orig_folder = test_case.gui.widgets('dest_folder').Value;

            test_case.choose(test_case.gui.widgets('function'), 'Delete files');
            test_case.verifyEqual(test_case.gui.widgets('dest_folder').Value, 'RecycleBin');

            test_case.choose(test_case.gui.widgets('function'), 'Move files');
            test_case.verifyEqual(test_case.gui.widgets('dest_folder').Value, orig_folder);
        end

        function test_disable_rename(test_case)
            %tests that all find and rename components are disabled when delete
            %files function is selected.
            import matlab.unittest.constraints.IsTrue
            test_case.choose(test_case.gui.widgets('function'), 'Delete files');
            components = {'to', 'dest_folder', 'dest_select', 'rename_title', 'find_text', ...
                'find', 'replace_text', 'replace', 'prefix_text', 'prefix', 'suffix_text', ...
                'suffix', 'regexp', 'rename_duplicate'};
            for c = 1:length(components)
                test_case.verifyThat(~test_case.gui.widgets(components{c}).Enable, IsTrue);
            end
        end
    end

    methods(Static)
        function set_widget_value(name, value)
            widget = test_case.gui.widgets(name);
            widget.Value = value;
        end
    end
end