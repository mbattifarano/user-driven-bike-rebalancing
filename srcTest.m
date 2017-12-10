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
            nConstraints = 2*p.N*p.N*p.T + 2*p.N*p.T + 1;
            dstar = rand(2*p.N*p.N*p.T, 1);
            actual = constraints(p, dstar);
            testCase.assertEqual(size(actual), [nConstraints, 1]);
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
            tol = p.lambda + 1000*eps;
            
            p.alphaO = 1;
            p.alphaD = 1;
            
            nVariables = 2*p.N*p.N*p.T;
            x1 = ones(nVariables, 1);
            fx1 = objective(p, x1);
            [grad_fO, grad_fD, ~, ~, ~, ~] = objectiveSubgradient(p, x1);
            identity = eye(nVariables);
            
            dfx1 = [grad_fO; grad_fD];
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
        
        function testSubgradientComponents(testCase)
            p = generateTestParameters();
            c = 100;
            u = rand(2*p.N*p.N*p.T + 2*p.N*p.T + 1, 1);
            tol = p.lambda + 1000*eps;
            
            nVariables = 2*p.N*p.N*p.T;
            x1 = ones(nVariables, 1);
            fx1 = augmentedLagrangian(p, c, u, x1);
            dfx1 = subgradAL(p, c, u, x1);
            identity = eye(nVariables);
            
            count = 0;
            for i = 1:nVariables
                ei = identity(:, i);
                x2 = x1 + ei;
                fx2 = augmentedLagrangian(p, c, u, x2);
                fx2_approx = fx1 + dot(dfx1, ei);
                fprintf("var %d: f(x2) = %0.4f; taylor(f)(x2) = %0.4f; error = %0.4f \n", ...
                        i, fx2, fx2_approx, fx2_approx - fx2);
                if abs(fx2_approx - fx2) > tol
                    count = count + 1;
                end
            end
            fprintf("%d\n", count);
            testCase.assertEqual(count, 0);
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