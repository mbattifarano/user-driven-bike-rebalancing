function [grad] = objectiveSubgradient(p, dstar)
%OBJECTIVESUBGRADIENT Compute the subgradient wrt the objective function
%   used internally to support the subgradient of the augmented lagrangian
    u = support();

    [dstarO, dstarD] = u.splitDstar(p, dstar);
    sign_fhat = signZero(sum(u.toStationTimeIndex(p, netFlow(p, dstarO, dstarD)), 2));
    dstarO = u.toStationTimeIndex(p, dstarO);
    dstarD = u.toStationTimeIndex(p, dstarD);
    cO = repmat(u.toStationTimeIndex(p, p.cO), [1, 1, p.T]);
    cD = repmat(u.toStationTimeIndex(p, p.cD), [1, 1, p.T]);
    % revI = repmat(abs(eye(p.N) - 1), [1, 1, p.T]);
    sign_fhat_i = repmat(reshape(sign_fhat, [p.N, 1, 1]), [1, p.N, p.T]);
    sign_fhat_j = repmat(reshape(sign_fhat, [1, p.N, 1]), [p.N, 1, p.T]);
    
    % objective function gradient
    gfO = (p.lambda * p.alphaO * (sign_fhat_i - sign_fhat_j));
    gfD = (p.lambda * p.alphaD * (sign_fhat_j - sign_fhat_i));
    grad_fO = gfO(:) + (p.alphaO * cO(:));
    grad_fD = gfD(:) + (p.alphaD * cD(:));
    grad = [grad_fO; grad_fD];
end

function [y] = signZero(x)
    y = sign(x);
    y(y==0) = 1;
end
