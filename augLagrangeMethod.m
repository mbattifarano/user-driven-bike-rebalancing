function [x, u, history] = augLagrangeMethod(parameters, opts, u_init, x_init)
%AUGLAGRANGEMETHOD
    x = x_init;
    u = u_init;
    c = opts.c0;
    history = [];
    for i = 1:opts.nIter
        [x, h] = subgradientDescent(parameters, opts.innerIter, c, u, x);
        h.c = c;
        fprintf("Outer iteration %d objective value = %0.4f.", objective(parameters, x)); 
        c = opts.beta * c;
        u = max(0,  u + c * constraints(parameters, x));
        history = [history h];
    end
end