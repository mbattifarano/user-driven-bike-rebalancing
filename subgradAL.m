function [grad] = subgradAL(parameters, ck, uj, dstar)
%SUBGRADAL Returns the subgradient of the augmented lagrangian at dstar, u
    p = parameters;
    u = support();
    
    [dstarO, dstarD] = u.splitDstar(p, dstar);
    dstarO = u.toStationTimeIndex(p, dstarO);
    dstarD = u.toStationTimeIndex(p, dstarD);
    cO = repmat(u.toStationTimeIndex(p, p.cO), [1, 1, p.T]);
    cD = repmat(u.toStationTimeIndex(p, p.cD), [1, 1, p.T]);
    revI = repmat(abs(eye(p.N) - 1), [1, 1, p.T]);  % "converse" identity (ones everywhere except the diagonal)
    
    % objective function gradient
    gfO = (2 * p.alphaO * revI);
    gfD = (2 * p.alphaD * revI);
    grad_fO = gfO(:) .* sign(dstarO(:)) .* (p.alphaO * cO(:));
    grad_fD = gfD(:) .* sign(dstarD(:)) .* (p.alphaD * cD(:));

    % constraint portion gradient
    g = constraints(p, dstar);
    gu = uj + ck * g;
    ggeq0 = (gu >= 0);

    % non-negative
    idx = 1:(p.N*p.N*p.T);
    grad_gO = -2 * ck * gu(idx) .* (p.alphaO * cO(:)) .* ggeq0(idx);

    idx = p.N*p.N*p.T + (1:(p.N*p.N*p.T));
    grad_gD = -2 * ck * gu(idx) .* (p.alphaD * cD(:)) .* ggeq0(idx);
    % Within budget
    idx = (2*p.N*p.N*p.T+1);
    grad_gO = grad_gO + 2 * ck * gu(idx) * p.alphaO * cO(:) * ggeq0(idx);
    grad_gD = grad_gD + 2 * ck * gu(idx) * p.alphaD * cD(:) * ggeq0(idx);
    % non-negative bikes
    idx = (2*p.N*p.N*p.T+1) + (1:(p.N*p.T));
    g_bike_min = 2 * ck * g(idx) .* ggeq0(idx);
    g_bike_min = cumsum(repmat(reshape(g_bike_min, [p.N, 1, p.T]), [1, p.N, 1]), 3);

    gfhatO = -gfO .* g_bike_min;
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = -gfD .* g_bike_min;
    grad_gD = grad_gD + gfhatD(:);

    % stations under capacity
    idx = (2*p.N*p.N*p.T + 1 + p.N*p.T) + (1:(p.N*p.T));
    g_bike_max = 2 * ck * g(idx) .* ggeq0(idx);
    g_bike_max = cumsum(repmat(reshape(g_bike_max, [p.N, 1, p.T]), [1, p.N, 1]), 3);

    gfhatO = gfO .* g_bike_max;
    grad_gO = grad_gO + gfhatO(:);
    gfhatD = gfD .* g_bike_max;
    grad_gD = grad_gD + gfhatD(:);

    % putting it all together
    grad = [grad_fO(:) + grad_gO(:); grad_fD(:) + grad_gD(:)];
end

