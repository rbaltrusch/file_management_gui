%Runs all tests in the tests/unit folder.
%
%Author: Richard Baltrusch
%Date: 26/11/2021

import matlab.unittest.plugins.TestReportPlugin
import matlab.unittest.plugins.CodeCoveragePlugin

src_folder = fullfile(unit_test_folder, '..', '..', 'src');
if ~isfolder('reports')
    mkdir('reports');
end

report_folder = fullfile('reports', 'unit');
unit_test_folder = fullfile(fileparts(mfilename('fullpath')), 'unit');
runner = testrunner;

plugin = TestReportPlugin.producingHTML(report_folder, 'IncludingPassingDiagnostics', true);
runner.addPlugin(plugin);

runner.addPlugin(CodeCoveragePlugin.forFolder(src_folder));
results = runner.run(testsuite(unit_test_folder));

disp(results);
open(fullfile(report_folder, 'index.html'));
