%Runs all tests in the tests/unit folder.
%
%To suppress test report generation, run:
%   run_tests('noReport')
%
%Author: Richard Baltrusch
%Date: 26/11/2021

function results = run_tests(varargin)
import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.plugins.CodeCoveragePlugin

if nargin
    generate_report = ~strcmp(varargin{1},'noReport');
else
    generate_report = true;
end

report_folder = fullfile('reports', 'unit');
unit_test_folder = fullfile(fileparts(mfilename('fullpath')), 'unit');

if generate_report
    src_folder = fullfile(unit_test_folder, '..', '..', 'src');
    if ~isfolder('reports')
        mkdir('reports');
    end
end

runner = testrunner;

if generate_report
    plugin = TestReportPlugin.producingHTML(report_folder, 'IncludingPassingDiagnostics', true);
    runner.addPlugin(plugin);

    runner.addPlugin(CodeCoveragePlugin.forFolder(src_folder, 'IncludingSubFolders', true));
end

%Run and display results
results = runner.run(testsuite(unit_test_folder));
disp(results);
if generate_report
    open(fullfile(report_folder, 'index.html'));
end

end
