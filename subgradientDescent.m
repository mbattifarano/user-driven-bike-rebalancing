function [x, history] = subgradientDescent(parameters, nIter, ck, u, dstar_init)
%SUBGRADIENTDESCENT
    objValues = zeros(nIter, 1);
    augObjValues = zeros(nIter, 1);
    x = dstar_init;
    for i = 1:nIter
        direction = subgradAL(parameters, ck, u, x);
        %usersOld = sum(x);
        x = x - stepSize(i) * direction;
        %usersNew = sum(x);
        %fprintf("adding %0.2f incentivized users.\n", usersNew - usersOld);
        x = max(0, x);
        objValues(i) = objective(parameters, x);
        augObjValues(i) = augmentedLagrangian(parameters, ck, u, x);
        %fprintf("Inner iteration %d of %d. objective value = %02.f. augmented objective value = %04f\n", ...
        %        i, nIter, objValues(i), augObjValues(i));
    end
    history = struct();
    history.objectiveValues = objValues;
    history.augmentedLagrangianValues = augObjValues;
end

function [t] = stepSize(k)
    t = 1/(k*10^4);
    %t = 10^-3;
end