function tests = test_package_1
tests = functiontests(localfunctions);
end

function test_function1(testCase)
    import matlab.unittest.constraints.IsTrue
    condition = 1 == 1;
    verifyThat(testCase,condition,IsTrue);
end

function test_function2(testCase)
import matlab.unittest.constraints.IsTrue
condition = strcmp('a','b');
verifyThat(testCase,condition,IsTrue);
end