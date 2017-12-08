function [values] = constraints(parameters, dstar)
%CONSTRAINTS Computes the value of the constraint functions at dstar
%   INPUTS
%       parameters  struct  parameter and data struct
%       dstart      nx1     objective variable
%
% All constraints are converted to the form g_i(dstar) <= 0
    p = parameters;
    u = support();
    cO = repmat(u.toStationTimeIndex(p, p.cO), [1, 1, p.T]);
    cD = repmat(u.toStationTimeIndex(p, p.cD), [1, 1, p.T]);
    s = repmat(p.s, [1, p.T]);
    b = repmat(p.b, [1, p.T]);
    [dstarO, dstarD] = u.splitDstar(p, dstar);
    bike_count = cumsum(u.toStationTimeIndex(p, netFlow(p, dstarO, dstarD)), 2);
    values = [
        dstar;
        p.alphaO * dot(cO(:), dstarO(:)) + p.alphaD * dot(cD(:), dstarD(:)) - p.C;
        -s(:) - bike_count(:);
        s(:) + bike_count(:) - b(:)
    ];
end

