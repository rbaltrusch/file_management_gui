function tests = main_test
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
%runs only once before all the tests in this file are run
testCase.TestData.a = 1;
end

function teardownOnce(testCase)
%runs only once after all the tests in this file are run
end

function setup(testCase)
%runs before every test case
end

function teardown(testCase)
%runs after every test case
end

function test_function1(testCase)
lib.test_package_1()
end

function test_function2(testCase)
import matlab.unittest.constraints.IsTrue
condition = strcmp('a','b');
verifyThat(testCase,condition,IsTrue);
end
