%Tests src/+gui folder and src/run_gui.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function tests = test_gui
tests = functiontests(localfunctions);
end

function setupOnce(~)
    %runs only once before all the tests in this file are run
    %add functions under test to path
    addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', 'src')));
end

function setup(test_case)
    %runs before every test case
    colour = [150 150 255] / 256;
    builder = gui.Builder(colour);
    test_case.TestData.gui = gui.Gui(builder);
end

function teardown(~)
    %runs after every test case
    figures = findall(0, 'type', 'figure');
    close(figures);
end

function test_run_gui(~)
    run_gui();
end

function test_gui_build(test_case)
    test_case.TestData.gui.build();
end

function test_gui_filter_files(test_case)
end

function test_gui_run_selected_function(test_case)
end
