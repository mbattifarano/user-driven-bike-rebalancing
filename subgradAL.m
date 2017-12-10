function [grad] = subgradAL(parameters, ck, uj, dstar)
%SUBGRADAL Returns the subgradient of the augmented lagrangian at dstar, u
    p = parameters;
    
    [grad_fO, grad_fD, gfO, gfD, cO, cD] = objectiveSubgradient(p, dstar);

    % constraint portion gradient
    gu = 2 * ck * max(0, uj + ck * constraints(p, dstar));

    %non-negative
    idx = 1:(p.N*p.N*p.T);
    grad_gO = -gu(idx);

    idx = p.N*p.N*p.T + (1:(p.N*p.N*p.T));
    grad_gD = -gu(idx);
    
    % Within budget
    idx = (2*p.N*p.N*p.T+1);
    grad_gO = grad_gO + gu(idx) * p.alphaO * cO(:);
    grad_gD = grad_gD + gu(idx) * p.alphaD * cD(:);
    
    % non-negative bikes
    idx = (2*p.N*p.N*p.T+1) + (1:(p.N*p.T));
    g_bike_min_i = flip(cumsum(repmat(reshape(gu(idx), [p.N, 1, p.T]), [1, p.N, 1]), 3), 3);
    g_bike_min_j = flip(cumsum(repmat(reshape(gu(idx), [1, p.N, p.T]), [p.N, 1, 1]), 3), 3);

    gfhatO = -p.alphaO * (g_bike_min_i - g_bike_min_j);
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = -p.alphaD * (g_bike_min_j - g_bike_min_i);
    grad_gD = grad_gD + gfhatD(:);

    % stations under capacity
    idx = (2*p.N*p.N*p.T + 1 + p.N*p.T) + (1:(p.N*p.T));
    g_bike_max_i = flip(cumsum(repmat(reshape(gu(idx), [p.N, 1, p.T]), [1, p.N, 1]), 3), 3);
    g_bike_max_j = flip(cumsum(repmat(reshape(gu(idx), [1, p.N, p.T]), [p.N, 1, 1]), 3), 3);

    gfhatO = p.alphaO * (g_bike_max_i - g_bike_max_j);
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = p.alphaD * (g_bike_max_j - g_bike_max_i);
    grad_gD = grad_gD + gfhatD(:);
    
    % 1/2c coefficient
    grad_gO = grad_gO / (2*ck);
    grad_gD = grad_gD / (2*ck);

    % putting it all together
    grad = [grad_fO(:) + grad_gO(:); grad_fD(:) + grad_gD(:)];
end

