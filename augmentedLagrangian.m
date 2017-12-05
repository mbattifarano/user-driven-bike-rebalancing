function [value] = augmentedLagrangian(parameters, c, u, dstar)
%AUGMENTEDLAGRANGIAN Returns the value of the augmented lagrangian 
%   Inputs
%       parameters  (struct)    parameter struct
%       dstar       (nx1)       optimization variables
%       u           (mx1)       lagrange multipliers
    p = parameters;
    f = objective(p, dstar);
    g = constraints(p, dstar);
    value = f + (1/(2*c)) * sum( max(0, u + c * g).^2 - u.^2 );
end
