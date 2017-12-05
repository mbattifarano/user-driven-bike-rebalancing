function [grad] = subgradAL(parameters, ck, u, dstar)
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
    grad_fO = (2 * p.alphaO * revI) .* sign(dstarO(:)) .* (p.alphaO * cO);
    grad_fD = (2 * p.alpahD * revI) .* sign(dstarD(:)) .* (p.alphaD * cD);
    
    % constraint portion gradient
    g = constaints(p, dstar);
    gu = u + ck * g;
    ggeq0 = (gu >= 0);
    
    % non-negative
    idx = 1:(p.N*p.N*P.T);
    grad_gO = -2 * ck * gu(idx) .* (p.alphaO * cO(:)) .* ggeq0(idx);
    idx = p.N*p.N*P.T + (1:(p.N*p.N*P.T));
    grad_gD = -2 * ck * gu(idx) .* (p.alphaD * cD(:)) .* ggeq0(idx);
    % Within budget
    idx = (2*p.N*p.N*P.T+1);
    grad_gO = grad_gO + 2 * ck * gu(idx) * p.alphaO * cO(:) * ggeq0(idx);
    grad_gD = grad_gD + 2 * ck * gu(idx) * p.alphaD * cD(:) * ggeq0(idx);
    % non-negative bikes
    % TODO
    idx = (2*p.N*p.N*P.T+1) + (1:(p.N*p.T));
    gfhatO = (2 * p.alphaO * revI);
    gfhatD = (2 * p.alpahD * revI);
    
    
    
    gradO = zeros(size(dstarO));
    gradD = zeros(size(dstarD));
    
    
    
    grad = [gradO(:); gradD(:)];
end

