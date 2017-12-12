%% Run optimization

fprintf("Preparing data and parameters.\n");
%% Setup problem parameters/data
p = Initialization();

% convert to column matrices
p.dO = p.dO(:);
p.dD = p.dD(:);
p.cO = p.cO(:);
p.cD = p.cD(:);
p.dOinc = p.dOinc(:);
p.dDinc = p.dDinc(:);

%% Setup optimization parameters

opts = struct();

opts.nIter = 10;
opts.innerIter = 5;
opts.c0 = 1.5;
opts.beta = 2;

%% Run algorithm

nConstraints = 2*p.N*p.N*p.T + 2*p.N*p.T + 1;
u_init = zeros(nConstraints, 1);
x_init = zeros(2*p.N*p.N*p.T, 1);

fprintf("Starting optimization.\n")
[x, u, history] = augLagrangeMethod(p, opts, u_init, x_init);