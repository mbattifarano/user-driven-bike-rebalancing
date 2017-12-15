function [grad] = subgradAL(parameters, ck, u, dstar)
%SUBGRADAL Returns the subgradient of the augmented lagrangian at dstar, u
    p = parameters;
    
    grad_f = objectiveSubgradient(p, dstar);
    grad_g = constraintGradient(p, ck, u, dstar);
    grad = grad_f + grad_g;
end

