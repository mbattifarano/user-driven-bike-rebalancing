function [x] = subgradientDescent(parameters, nIter, ck, u, dstar_init)
%SUBGRADIENTDESCENT
    x = dstar_init;
    for i = 1:nIter
        % TODO: save state to history struct
        x = x + stepSize(i) * subgradAL(parameters, ck, u, x);
    end
end

function [t] = stepSize(k)
    t = 1/(k^2);
end

