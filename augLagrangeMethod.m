function [x, u, history] = augLagrangeMethod(parameters, opts, u_init, x_init)
%AUGLAGRANGEMETHOD
    x = x_init;
    u = u_init;
    c = opts.c0;
    history = [];
    fprintf("Initial objective value: %0.4f. augmented objective value: %0.4f.\n",...
            objective(parameters, x), augmentedLagrangian(parameters, c, u, x));
%     violated = find(constraints(parameters, x_init) > (0+eps));
%     if ~isempty(violated)
%         %disp(violated);
%         error("Initial solution violates constraints");
%     end
    for i = 1:opts.nIter
        fprintf("c=%0.2f\n", c);
        [x, h] = subgradientDescent(parameters, opts.innerIter, opts.gamma, c, u, x);
        constraints(parameters, x, 1);
        h.c = c;
        fprintf("Outer iteration %d: objective value = %0.4f. augmented objevtive = %0.4f.\n", ...
                i, h.objectiveValues(end), h.augmentedLagrangianValues(end));
        u = max(0,  u + c * constraints(parameters, x));
        c = opts.beta * c;
        history = [history h];
    end
end