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
    p.C = 100;          %   daily budget for incentives
    p.lambda = 2.5;     %   cost to rebalance a bike manually
    p.alphaO = 0.75;    %   cooperativeness parameter for switching origins
    p.alphaD = 0.5;    %   cooperativeness parameter for switching destinations
    p.b = randi([5, 10], p.N, 1);   % station capacity

    cO = rand(p.N, p.N) * 5;
    cD = rand(p.N, p.N) * 2.5;
    p.cO = cO(:);
    p.cD = cD(:);   % incentive required to change origin or desination station
    p.s = floor(p.b / 2);   % initial number of bicycles at each station

    p.dO = populateDemandMatrix(p, -1); % O-D-t travel demand
    p.dD = populateDemandMatrix(p, -1); % O-D-t travel demand
    
    p.dOinc = populateDemandMatrix(p, 3); % O-D-t travel demand that has already accepted an incentive
    p.dDinc = populateDemandMatrix(p, 4); % O-D-t travel demand that has already accepted an incentive
    %% computed data
    
    fout = squeeze(sum(reshape(p.dO, p.N, p.N, p.T), 2));
    p.fout = fout(:);   % number of bikes leaving station i at time t
    fin = squeeze(sum(reshape(p.dD, p.N, p.N, p.T), 1));
    p.fin = fin(:);     % number of bikes arriving to station i at time t
    
    %TODO: pull these out to their own functions
    p.foutstar = @(dstarO)(utils.computeIncentivizedFlow(p, p.alphaO, p.dOinc, dstarO)); % incentivized flow out
    p.finstar = @(dstarD)(utils.computeIncentivizedFlow(p, p.alphaD, p.dDinc, dstarD)); % incentivized flow in
    
    p.fhat = @(dstarO, dstarD)((p.fin + p.finstar(dstarD)) - (p.fout + p.foutstar(dstarO))); % net flow

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