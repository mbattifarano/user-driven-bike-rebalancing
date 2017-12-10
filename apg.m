function [x, t] = apg(grad_f, prox_h, dim_x, opts)
%
% apg v0.1b (@author bodonoghue)
% https://github.com/bodono/apg/blob/master/apg.m
%
% Implements an Accelerated Proximal Gradient method
% (Nesterov 2007, Beck and Teboulle 2009)
%
% solves: min_x (f(x) + h(x)), x \in R^dim_x
%
% where f is smooth, convex and h is non-smooth, convex but simple
% in that we can easily evaluate the proximal operator of h
%
% returns solution and last-used step-size (the step-size is useful
% if you're solving a similar problem many times serially, you can
% initialize apg with the last use step-size
%
% this takes in two function handles:
% grad_f(v,opts) = df(v)/dv (gradient of f)
% prox_h(v,t,opts) = argmin_x (t*h(x) + 1/2 * norm(x-v)^2)
%                       where t is the step size at that iteration
% if h = 0, then use prox_h = [] or prox_h = @(x,t,opts)(x)
% put the necessary function data in opts fields
%
% implements something similar to TFOCS step-size adaptation (Becker, Candes and Grant 2010)
% and gradient-scheme adaptive restarting (O'Donoghue and Candes 2013)
%
% quits when norm(y(k) - x(k+1)) < EPS * max(1, norm(x(k+1))
%
% optional opts fields defined are below (with defaults)
% to use defaults simply call apg with opts = []
X_INIT = zeros(dim_x,1); % initial starting point
USE_RESTART = true; % use adaptive restart scheme
MAX_ITERS = 2000; % maximum iterations before termination
EPS = 1e-6; % tolerance for termination
ALPHA = 1.01; % step-size growth factor
BETA = 0.5; % step-size shrinkage factor
QUIET = false; % if false writes out information every 100 iters
GEN_PLOTS = true; % if true generates plots of norm of proximal gradient
USE_GRA = false; % if true uses UN-accelerated proximal gradient descent (typically slower)
STEP_SIZE = []; % starting step-size estimate, if not set then apg makes initial guess
FIXED_STEP_SIZE = false; % don't change step-size (forward or back tracking), uses initial
% step-size throughout, only useful if good
% STEP_SIZE set

if (~isempty(opts))
    if isfield(opts,'X_INIT');X_INIT = opts.X_INIT;end
    if isfield(opts,'USE_RESTART');USE_RESTART = opts.USE_RESTART;end
    if isfield(opts,'MAX_ITERS');MAX_ITERS = opts.MAX_ITERS;end
    if isfield(opts,'EPS');EPS = opts.EPS;end
    if isfield(opts,'ALPHA');ALPHA = opts.ALPHA;end
    if isfield(opts,'BETA');BETA = opts.BETA;end
    if isfield(opts,'QUIET');QUIET = opts.QUIET;end
    if isfield(opts,'GEN_PLOTS');GEN_PLOTS = opts.GEN_PLOTS;end
    if isfield(opts,'USE_GRA');USE_GRA = opts.USE_GRA;end
    if isfield(opts,'STEP_SIZE');STEP_SIZE = opts.STEP_SIZE;end
    if isfield(opts,'FIXED_STEP_SIZE');FIXED_STEP_SIZE = opts.FIXED_STEP_SIZE;end
end

% if quiet don't generate plots
GEN_PLOTS = GEN_PLOTS & ~QUIET;

if (GEN_PLOTS); errs = zeros(MAX_ITERS,2);end

x = X_INIT; y=x;
g = grad_f(y,opts);
theta = 1;

if (isempty(STEP_SIZE) || isnan(STEP_SIZE))
    if(false)
        % perturbation for first step-size estimate:
        T = 10; dx = T*ones(dim_x,1); g_hat = nan;
        while any(isnan(g_hat))
            dx = dx/T;
            x_hat = x + dx;
            g_hat = grad_f(x_hat,opts);
        end
        t = norm(x - x_hat)/norm(g - g_hat);
    else
        % Barzilai-Borwein step-size initialization:
        t = 1 / norm(g);
        x_hat = x - t*g;
        g_hat = grad_f(x_hat,opts);
        t = abs(( x - x_hat )'*(g - g_hat) / (norm(g - g_hat)^2));
    end
    clear x_hat g_hat
else
    t = STEP_SIZE;
end

for k=1:MAX_ITERS
    
    if (~QUIET && mod(k,100)==0)
        fprintf('iter num %i, norm(tGk): %1.2e, step-size: %1.2e\n',k,err1,t);
    end
    
    x_old = x;
    y_old = y;
    
    x = y - t*g;
    
    if ~isempty(prox_h)
        x = prox_h(x,t,opts);
    end
    
    err1 = norm(y-x)/max(1,norm(x));
    
    if (GEN_PLOTS);
        errs(k,1) = err1;
        %err2 = norm(x-x_old)/max(1,norm(x));
        %errs(k,2) = err2;
    end
    
    if (err1 < EPS)
        break;
    end
    
    if(~USE_GRA)
        theta = 2/(1 + sqrt(1+4/(theta^2)));
    else
        theta = 1;
    end
    
    if (USE_RESTART && (y-x)'*(x-x_old)>0)
        x = x_old;
        y = x;
        theta = 1;
    else
        y = x + (1-theta)*(x-x_old);
    end
    
    g_old = g;
    g = grad_f(y,opts);
    
    % TFOCS-style backtracking:
    if (~FIXED_STEP_SIZE)
        t_hat = 0.5*(norm(y-y_old)^2)/abs((y - y_old)'*(g_old - g));
        t = min( ALPHA*t, max( BETA*t, t_hat ));
    end
    
end
if (~QUIET)
    fprintf('iter num %i, norm(tGk): %1.2e, step-size: %1.2e\n',k,err1,t);
    fprintf('Terminated\n');
end
if (GEN_PLOTS)
    errs = errs(1:k,:);
    figure();semilogy(errs(:,1));
    xlabel('iters');title('norm(tGk)')
    %figure();semilogy(errs(:,2));
    %xlabel('iters');title('norm(Dxk)')
end

end