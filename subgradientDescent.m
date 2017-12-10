function [x, history] = subgradientDescent(parameters, nIter, ck, u, dstar_init)
%SUBGRADIENTDESCENT
    objValues = zeros(nIter, 1);
    augObjValue = zeros(nIter, 1);
    x = dstar_init;
    for i = 1:nIter
        % TODO: save state to history struct
        x = x + stepSize(i) * subgradAL(parameters, ck, u, x);
        objValues(i) = objective(parameters, x);
        augObjValues(i) = augmentedLagrangian(parameters, ck, u, x);
    end
    history = struct();
    history.objectiveValues = objValues;
    history.augmentedLagrangianValues = augObjValues;
end

function [t] = stepSize(k)
    t = 1/(k^2);
end

