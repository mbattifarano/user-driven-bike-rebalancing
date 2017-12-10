function [x, u, history] = augLagrangeMethod(parameters, opts, u_init, x_init)
%AUGLAGRANGEMETHOD
    x = x_init;
    u = u_init;
    c = opts.c0;
    history = [];
    fprintf("Initial objective value: %0.4f. augmented objective value: %0.4f.\n",...
            objective(parameters, x), augmentedLagrangian(parameters, c, u, x));
    for i = 1:opts.nIter
        [x, h] = subgradientDescent(parameters, opts.innerIter, c, u, x);
        h.c = c;
        fprintf("Outer iteration %d: objective value = %0.4f. augmented objevtive = %0.4f.\n", ...
                i, h.objectiveValues(end), h.augmentedLagrangianValues(end));
        c = opts.beta * c;
        u = max(0,  u + c * constraints(parameters, x));
        history = [history h];
    end
end