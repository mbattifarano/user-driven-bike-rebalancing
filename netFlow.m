function [fhat] = netFlow(p, dstarO, dstarD)
%NETFLOW 
    utils = support();

    fout = squeeze(sum(reshape(p.dO, p.N, p.N, p.T), 2));
    fout = fout(:);   % number of bikes leaving station i at time t
    fin = squeeze(sum(reshape(p.dD, p.N, p.N, p.T), 1));
    fin = fin(:);     % number of bikes arriving to station i at time t

    foutstar = utils.computeIncentivizedFlow(p, p.alphaO, p.dOinc, dstarO); % incentivized flow out
    finstar = utils.computeIncentivizedFlow(p, p.alphaD, p.dDinc, dstarD); % incentivized flow in
    
    fhat = ((fin + finstar) - (fout + foutstar));
end

