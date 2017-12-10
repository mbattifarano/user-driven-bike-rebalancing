function [parameters] = generateTestParameters()
%GENERATETESTPARAMETERS generate a set of parameters for testing
    %% setup
    SEED = 123;
    rng(SEED);  % set the random seed for reproducibility

    p = struct();
    utils = support();
    
    %% given data
    p.N = 5;            %   number of stations
    p.T = 3;            %   number of timesteps
    p.C = 1000;          %   daily budget for incentives
    p.lambda = 3;     %   cost to rebalance a bike manually
    p.alphaO = 0.75;    %   cooperativeness parameter for switching origins
    p.alphaD = 0.5;    %   cooperativeness parameter for switching destinations
    p.b = randi([5, 10], p.N, 1);   % station capacity

    cO = rand(p.N, p.N) * 5;
    cD = rand(p.N, p.N) * 2.5;
    p.cO = cO(:);
    p.cD = cD(:);   % incentive required to change origin or desination station
    p.s = floor(p.b / 2);   % initial number of bicycles at each station

    p.dO = zeros(p.N*p.N*p.T, 1); %populateDemandMatrix(p, -1); % O-D-t travel demand
    p.dD = zeros(p.N*p.N*p.T, 1); %populateDemandMatrix(p, -1); % O-D-t travel demand
    
    p.dOinc = populateDemandMatrix(p, 3); % O-D-t travel demand that has already accepted an incentive
    p.dDinc = populateDemandMatrix(p, 4); % O-D-t travel demand that has already accepted an incentive

    parameters = p;
end

function [demand] = populateDemandMatrix(p, n)
    if n < 0
        totalBikes = sum(p.s(:));
    else
        totalBikes = n;
    end
    demand = zeros(p.N, p.N, p.T);
    while (sum(demand(:)) < totalBikes)
        i = randi([1, p.N]);
        j = randi([1, p.N]);
        t = randi([1, p.T]);
        if i ~= j % no demand from station to itself
            demand(i, j, t) = demand(i, j, t) + 1;
        end
    end
    demand = demand(:);
end