function [value] = objective(parameters, dstar)
%OBJECTIVE Compute the value of the objevtice function at dstar
%   INPUTS
%       parameters  struct          parameter and data struct
%       dstar       (2*n*n*t)x1     objective variable
    p = parameters;
    u = support();
    [dstarO, dstarD] = u.splitDstar(p, dstar);
    cO = repmat(u.toStationTimeIndex(p, p.cO), [1, 1, p.T]);
    cD = repmat(u.toStationTimeIndex(p, p.cD), [1, 1, p.T]);
    fhat = u.toStationTimeIndex(p, p.fhat(dstarO, dstarD));
    value = p.lambda * sum(abs(sum(fhat, 2)), 1) + ...
            p.alphaO * dot(cO(:), dstarO(:)) + ...
            p.alphaD * dot(cD(:), dstarD(:));
end

