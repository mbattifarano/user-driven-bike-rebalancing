function [x, u] = augLagrangeMethod(parameters, opts, u_init, x_init)
%AUGLAGRANGEMETHOD
    x = x_init;
    u = u_init;
    c = opts.c0;
    for i = 1:opts.nIter
        % TODO: Save state to history struct
        x = subgradientDescent(parameters, opts.innerIter, c, u, x);
        c = opts.beta * c;
        u = max(0, u + c * constraints(parameters, x));
    end
end