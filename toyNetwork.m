clear all;
p = generateTestParameters();

dstar = ones(2*p.N*p.N*p.T, 1);
u = rand(2*p.N*p.N*p.T + 2*p.N*p.T + 1, 1);

trivial_solution = 0*dstar;

violated = find(constraints(p, trivial_solution, 1) > 0);
if ~isempty(violated)
    error("Trivial solution violates constraints");
end

opts = struct();
opts.nIter = 150;
opts.innerIter = 2000;
opts.c0 = 1.5;
opts.beta = 2;
opts.gamma = 100;

gamma_vals = [50];
c0_vals = [100];
beta_vals = [2];

parameter_grid = allcomb(gamma_vals, c0_vals, beta_vals);
nCombs = size(parameter_grid, 1);

objValues = zeros(opts.nIter*opts.innerIter, nCombs);
solutions = zeros(2*p.N*p.N*p.T, nCombs);

%%
for i = 1:nCombs
    row = parameter_grid(i, :);
    fprintf("Running with parameters:");
    disp(row);
    opts.gamma = row(1);
    opts.c0 = row(2);
    opts.beta = row(3);
    
    [actual_dstar, actual_u, history] = augLagrangeMethod(p, opts, u, dstar);
    solutions(:, i) = actual_dstar;
    objValues(:, i) = vertcat(history(:).objectiveValues); 
end

%%

startIdx = 1;

gammas = parameter_grid(:,1);

figure;
semilogy(objValues(:, startIdx:end));
ylim([1, 500]);
title("Convergence with different step size multipliers");
xlabel("iterations");
ylabel("objective value ($)");

labels = {};
for i = startIdx:length(gammas)
   labels = horzcat(labels, sprintf("\\gamma = %d", gammas(i)));
end
legend(labels);