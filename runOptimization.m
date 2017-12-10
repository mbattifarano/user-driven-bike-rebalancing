%% Run optimization

fprintf("Preparing data and parameters.");
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

o = struct();

opts.nIter = 10;
opts.innerIter = 5;
opts.c0 = 4;
opts.beta = 8;

%% Run algorithm

nConstraints = 2*p.N*p.N*p.T + 2*p.N*p.T + 1;
u_init = zeros(nConstraints, 1);
x_init = zeros(p.N*p.N*p.T, 1);

fprintf("Starting optimization.")
[x, u, history] = augLagrangeMethod(p, o, u_init, x_init);