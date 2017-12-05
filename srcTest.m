classdef srcTest < matlab.unittest.TestCase
    methods (Test)
        function testGenerateParameters(testCase)
            p = generateTestParameters();
            testCase.assertEqual(sum(p.dO), sum(p.s));
            testCase.assertEqual(sum(p.dD), sum(p.s));
            testCase.assertEqual(sum(p.dOinc), 3);
            testCase.assertEqual(sum(p.dDinc), 4);
        end

        function testToStationTimeIndex(testCase)
            utils = support();
            p = generateTestParameters();

            d1 = zeros(p.N*p.T, 1);
            testCase.assertEqual(size(utils.toStationTimeIndex(p, d1)), [p.N, p.T]);
            d2 = zeros(p.N*p.N*p.T, 1);
            testCase.assertEqual(size(utils.toStationTimeIndex(p, d2)), [p.N,  p.N, p.T]);
            d3 = zeros(p.N, p.N);
            testCase.assertError(@()(utils.toStationTimeIndex(p, d3)),  "toStationTimeIndex:badDimension");
            d4 = zeros(p.N, 1);
            testCase.assertError(@()(utils.toStationTimeIndex(p, d4)), "toStationTimeIndex:badNumel");
        end

        function testfin(testCase)
            p = generateTestParameters();
            u = support();
            dD = u.toStationTimeIndex(p, p.dD);
            expected = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    for j = 1:p.N
                        expected(i, t) = expected(i, t) + dD(j, i, t);
                    end
                end
            end
            actual = p.fin;
            testCase.assertEqual(actual, expected(:));
        end

        function testfout(testCase)
            p = generateTestParameters();
            u = support();
            dO = u.toStationTimeIndex(p, p.dO);
            expected = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    for j = 1:p.N
                        expected(i, t) = expected(i, t) + dO(i, j, t);
                    end
                end
            end
            actual = p.fout;
            testCase.assertEqual(actual, expected(:));
        end

        function testfoutstar(testCase)
            p = generateTestParameters();
            u = support();
            dstarO = randi(2, p.N, p.N, p.T);
            dOinc = u.toStationTimeIndex(p, p.dOinc);
            actual = p.foutstar(dstarO(:));
            expected = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    for j = 1:p.N
                        expected(i, t) = expected(i, t) + ...
                                         (p.alphaO * dstarO(j, i, t) + dOinc(j, i, t)) - ...
                                         (p.alphaO * dstarO(i, j, t) + dOinc(i, j, t));
                    end
                end
            end
            testCase.assertEqual(actual, expected(:));
        end

        function testfinstar(testCase)
            p = generateTestParameters();
            u = support();
            dstarD = randi(2, p.N, p.N, p.T);
            dDinc = u.toStationTimeIndex(p, p.dDinc);
            actual = p.finstar(dstarD(:));
            expected = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    for j = 1:p.N
                        expected(i, t) = expected(i, t) + ...
                                         (p.alphaD * dstarD(j, i, t) + dDinc(j, i, t)) - ...
                                         (p.alphaD * dstarD(i, j, t) + dDinc(i, j, t));
                    end
                end
            end
            testCase.assertEqual(actual, expected(:));
        end

        function testfhat(testCase)
            p = generateTestParameters();
            u = support();
            dO = u.toStationTimeIndex(p, p.dO);
            dD = u.toStationTimeIndex(p, p.dD);
            dstarO = randi(2, p.N, p.N, p.T);
            dstarD = randi(2, p.N, p.N, p.T);
            dOinc = u.toStationTimeIndex(p, p.dOinc);
            dDinc = u.toStationTimeIndex(p, p.dDinc);
            actual = p.fhat(dstarO(:), dstarD(:));
            expected = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    for j = 1:p.N
                        expected(i, t) = expected(i, t) + ...
                                         (dD(j, i, t) + ...
                                          (p.alphaD * dstarD(j, i, t) + dDinc(j, i, t)) - ...
                                          (p.alphaD * dstarD(i, j, t) + dDinc(i, j, t))) - ...
                                         (dO(i, j, t) + ...
                                          (p.alphaO * dstarO(j, i, t) + dOinc(j, i, t)) - ...
                                          (p.alphaO * dstarO(i, j, t) + dOinc(i, j, t)));
                    end
                end
            end
            testCase.assertEqual(actual, expected(:));
        end
        
        function testSplitDstar(testCase)
            p = generateTestParameters();
            u = support();
            dstar = rand(2*p.N*p.N*p.T, 1);
            [dstarO, dstarD] = u.splitDstar(p, dstar);
            testCase.assertEqual(size(dstarO), [p.N*p.N*p.T, 1]);
            testCase.assertEqual(size(dstarD), [p.N*p.N*p.T, 1]);
            testCase.assertEqual(dstarO, dstar(1:p.N*p.N*p.T));
            testCase.assertEqual(dstarD, dstar((p.N*p.N*p.T+1):end));
        end
        
        function testObjective(testCase)
            p = generateTestParameters();
            u = support();
            dstar = rand(2*p.N*p.N*p.T, 1);
            actual = objective(p, dstar);
            
            first_term = 0;
            second_term = 0;
            [dstarO, dstarD] = u.splitDstar(p, dstar);
            % first term
            fhat = u.toStationTimeIndex(p, p.fhat(dstarO, dstarD));
            for i = 1:p.N
                time_sum = 0;
                for t = 1:p.T
                    time_sum = time_sum + fhat(i, t);
                end
                first_term = first_term + abs(time_sum);
            end
            first_term = p.lambda * first_term;
            % second term
            cO = u.toStationTimeIndex(p, p.cO);
            cD = u.toStationTimeIndex(p, p.cD);
            dstarO_ = u.toStationTimeIndex(p, dstarO);
            dstarD_ = u.toStationTimeIndex(p, dstarD);
            for i = 1:p.N
                for j = 1:p.N
                    for t = 1:p.T
                        second_term = second_term + ...
                                      p.alphaO * cO(i,j) * dstarO_(i,j,t) + ...
                                      p.alphaD * cD(i,j) * dstarD_(i,j,t);
                    end
                end
            end
            expected = first_term + second_term;
            testCase.assertLessThan(abs(actual - expected), 0.00001);
        end
    end
end