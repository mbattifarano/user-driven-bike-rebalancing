function [grad] = constraintGradient(p, ck, u, dstar)
%CONSTRAINTGRADIENT 
    utils = support();

    cO = repmat(utils.toStationTimeIndex(p, p.cO), [1, 1, p.T]);
    cD = repmat(utils.toStationTimeIndex(p, p.cD), [1, 1, p.T]);

    gu = 2 * ck * max(0, u + ck * constraints(p, dstar));

    nVariables = p.N*p.N*p.T;
    grad_gO = zeros(nVariables, 1);
    grad_gD = zeros(nVariables, 1);
    %non-negative
    idx = 1:(nVariables);
    grad_gO = grad_gO - gu(idx);

    idx = nVariables + (1:(nVariables));
    grad_gD = grad_gD - gu(idx);
    
    % Within budget
    idx = (2*nVariables+1);
    grad_gO = grad_gO + gu(idx) * p.alphaO * cO(:);
    grad_gD = grad_gD + gu(idx) * p.alphaD * cD(:);
    
    % non-negative bikes
    idx = (2*nVariables+1) + (1:(p.N*p.T));
    g_bike_min_i = repmat(cumsum(reshape(gu(idx), [p.N, 1, p.T]), 3, 'reverse'), [1, p.N, 1]);
    g_bike_min_j = permute(g_bike_min_i, [2, 1, 3]);

    gfhatO = -p.alphaO * (g_bike_min_i - g_bike_min_j);
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = -p.alphaD * (g_bike_min_j - g_bike_min_i);
    grad_gD = grad_gD + gfhatD(:);
 
    % stations under capacity
    idx = (2*p.N*p.N*p.T + 1 + p.N*p.T) + (1:(p.N*p.T));
    g_bike_max_i = repmat(cumsum(reshape(gu(idx), [p.N, 1, p.T]), 3, 'reverse'), [1, p.N, 1]);
    g_bike_max_j = permute(g_bike_max_i, [2, 1, 3]);

    gfhatO = p.alphaO * (g_bike_max_i - g_bike_max_j);
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = p.alphaD * (g_bike_max_j - g_bike_max_i);
    grad_gD = grad_gD + gfhatD(:);
    
    % 1/2c coefficient
    grad = [grad_gO(:); grad_gD(:)]/ (2*ck);
end

