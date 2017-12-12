%% Run optimization

fprintf("Preparing data and parameters.\n");
%% Setup problem parameters/data
p = Initialization();

% p.b = p.b*2;
% p.s = p.b/2; % correct for supply infeasibility


% convert to column matrices
p.dO = p.dO(:);
p.dD = p.dD(:);
p.cO = p.cO(:);
p.cD = p.cD(:);
p.dOinc = p.dOinc(:);
p.dDinc = p.dDinc(:);

%% Setup optimization parameters

opts = struct();

opts.nIter = 20;
opts.innerIter = 1000;
opts.c0 = 5;
opts.beta = 5;

%% Run algorithm

nConstraints = 2*p.N*p.N*p.T + 2*p.N*p.T + 1;
u_init = zeros(nConstraints, 1);
x_init = ones(2*p.N*p.N*p.T, 1);

fprintf("Starting optimization.\n")
[x, u, history] = augLagrangeMethod(p, opts, u_init, x_init);

save(sprintf("results-%s.mat", datetime));