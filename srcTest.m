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

        function testfhat(testCase)
            p = generateTestParameters();
            u = support();
            dO = u.toStationTimeIndex(p, p.dO);
            dD = u.toStationTimeIndex(p, p.dD);
            dstarO = randi(2, p.N, p.N, p.T);
            dstarD = randi(2, p.N, p.N, p.T);
            dOinc = u.toStationTimeIndex(p, p.dOinc);
            dDinc = u.toStationTimeIndex(p, p.dDinc);
            actual = netFlow(p, dstarO(:), dstarD(:));
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
            fhat = u.toStationTimeIndex(p, netFlow(p, dstarO, dstarD));
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
        
        function testConstraints(testCase)
            p = generateTestParameters();
            u = support();
            nConstraints = 2*p.N*p.N*p.T + 2*p.N*p.T + 1;
            dstar = rand(2*p.N*p.N*p.T, 1);
            actual = constraints(p, dstar);
            testCase.assertEqual(size(actual), [nConstraints, 1]);
            
            [dstarO, dstarD] = u.splitDstar(p, dstar);
            fhat = reshape(netFlow(p, dstarO, dstarD), [p.N p.T]);
            expected_lower = zeros(p.N, p.T);
            expected_upper = zeros(p.N, p.T);
            for i = 1:p.N
                for t = 1:p.T
                    expected_lower(i, t) = -p.s(i) - sum(fhat(i, 1:t));
                    expected_upper(i, t) = p.s(i) + sum(fhat(i, 1:t)) - p.b(i);
                end
            end
            expected = [expected_lower(:); expected_upper(:)];
            testCase.assertEqual(actual((end-length(expected)+1):end), expected);
        end
        
        function testAugmentedLagrangian(testCase)
            p = generateTestParameters();
            dstar = rand(2*p.N*p.N*p.T, 1);
            u = rand(2*p.N*p.N*p.T + 2*p.N*p.T + 1, 1);
            c = 4;
            actual = augmentedLagrangian(p, c, u, dstar);
            testCase.assertEqual(size(actual), [1 1]);
        end

        function testFullOptimization(testCase)
            p = generateTestParameters();
            dstar = ones(2*p.N*p.N*p.T, 1);
            u = rand(2*p.N*p.N*p.T + 2*p.N*p.T + 1, 1);
            %u = rand(2*p.N*p.N*p.T, 1);
            opts = struct();
            opts.nIter = 5;
            opts.innerIter = 5;
            opts.c0 = 1.5;
            opts.beta = 2;
            f0 = objective(p, dstar);
            [actual_dstar, actual_u] = augLagrangeMethod(p, opts, u, dstar);
            %disp(actual_dstar);
            fstar = objective(p, actual_dstar);
            testCase.assertLessThan(fstar, f0);
            testCase.assertEqual(size(actual_dstar), size(dstar));
            testCase.assertNotEqual(actual_dstar, dstar);
            testCase.assertEqual(size(actual_u), size(u));
            testCase.assertNotEqual(actual_u, u);
            
        end
        
        function testObjectiveSubgradient(testCase)
            p = generateTestParameters();
            tol = 2*p.lambda + 1000*eps;
            
            p.alphaO = 1;
            p.alphaD = 1;
            
            nVariables = 2*p.N*p.N*p.T;
            x1 = ones(nVariables, 1);
            fx1 = objective(p, x1);
            dfx1 = objectiveSubgradient(p, x1);
            identity = eye(nVariables);
            
            count = 0;
            for i = 1:nVariables
                ei = identity(:, i);
                x2 = x1 + ei;
                fx2 = objective(p, x2);
                fx2_approx = fx1 + dot(dfx1, ei);
                approx_error =  fx2_approx - fx2;
                if abs(approx_error) > tol
                    count = count + 1;
                    fprintf("variable %d: f(x2) = %0.4f; taylor(f)(x2) = %0.4f; error = %0.4f;\n",...
                            i, fx2, fx2_approx, approx_error);
                end
            end
            testCase.assertEqual(count, 0);
        end
        
        function testConstraintSubgradient(testCase)
            p = generateTestParameters();
            c = 100;
            nVariables = 2*p.N*p.N*p.T;
            u = rand(nVariables + 1 + 2*p.N*p.T, 1);
            
            x1O = ones(p.N, p.N, p.T);
            x1D = ones(p.N, p.N, p.T);
            x1 = [x1O(:); x1D(:)];
            gu = 2 * c * max(0, u + c * constraints(p, x1));
            Opos = reshape(gu(1:(nVariables/2)), size(x1O));
            Dpos = reshape(gu((1+nVariables/2):nVariables), size(x1D));
            budget = gu(nVariables+1);
            bikespos = reshape(gu(nVariables+1+(1:p.N*p.T)), [p.N, p.T]);
            bikescap = reshape(gu(nVariables+1+p.N*p.T+(1:p.N*p.T)), [p.N, p.T]);
            expectedO = zeros(p.N, p.N, p.T);
            expectedD = zeros(p.N, p.N, p.T);
            for i = 1:p.N
                for j = 1:p.N 
                    for t = 1:p.T
                        expectedO(i, j, t) = ...
                            -Opos(i, j, t) + ...
                            p.alphaO * budget + ...
                            -p.alphaO * sum(bikespos(i, t:end) - bikespos(j, t:end)) + ...
                            p.alphaO * sum(bikescap(i, t:end) - bikescap(j, t:end));
                        expectedD(i, j, t) = ...
                            -Dpos(i, j, t) + ...
                            p.alphaD * budget + ...
                            -p.alphaD * sum(bikespos(j, t:end) - bikespos(i, t:end)) + ...
                            p.alphaD * sum(bikescap(j, t:end) - bikescap(i, t:end));
                    end
                end
            end
            expected = [expectedO(:); expectedD(:)]/(2*c);
            actual = constraintGradient(p, c, u, x1);
            %fprintf("%0.2f\n", norm(expected - actual));
            testCase.assertEqual(actual, expected);
        end
        
        function testSubgradient(testCase)
            p = generateTestParameters();
            c = 100;
            u = rand(2*p.N*p.N*p.T + 2*p.N*p.T + 1, 1);
            
            x1 = zeros(2*p.N*p.N*p.T, 1);
            fx1 = augmentedLagrangian(p, c, u, x1);
            
            x2 = ones(2*p.N*p.N*p.T, 1);
            fx2 = augmentedLagrangian(p, c, u, x2);
            
            df = subgradAL(p, 100, u, x1);
            fx2_approx = fx1 + dot(df, x2-x1);
            fprintf("f(x2) = %0.4f; taylor(f)(x2) = %0.4f;", fx2, fx2_approx);
            % testCase.assertLessThan(abs(fx2 - fx2_approx), 0.001);
        end

        function testLargeDemand(testCase)
        end
    end
end