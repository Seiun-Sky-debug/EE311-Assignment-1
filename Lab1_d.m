%% Root-locus full script: find imaginary-axis crossing (Part d)
clear; close all; clc;

% Parameters
g  = 121;
p1 = 4;
p2 = 3;
p3 = 5;

% Open-loop transfer function without k
num0 = g;
den0 = conv(conv([1 p1],[1 p2]), [1 p3]);   % (s+p1)(s+p2)(s+p3)
L0 = tf(num0, den0);

% Plot root locus
figure('Name','Root Locus with Imaginary-axis Crossing');
rlocus(L0); grid on;
title('Root Locus of k*g/((s+4)(s+3)(s+5))  (k varies)');
xlabel('Real Axis'); ylabel('Imaginary Axis');
hold on;

%% --- Method 1: Symbolic solution ---
% Solve real(expr)=0 and imag(expr)=0 for w>0 and k real
syms w_sym k_sym real
s_sym = 1i * w_sym;
expr = (s_sym + p1)*(s_sym + p2)*(s_sym + p3) + k_sym * g;
eq_real = simplify(real(expr));
eq_imag = simplify(imag(expr));

sol = solve([eq_real==0, eq_imag==0], [w_sym, k_sym], ...
            'Real', true, 'MaxDegree', 4);

% Collect valid real solutions
w_candidates = [];
k_candidates = [];

if ~isempty(sol)
    wvals = double(sol.w_sym);
    kvals = double(sol.k_sym);

    for ii = 1:length(wvals)
        if isreal(wvals(ii)) && isreal(kvals(ii)) && (wvals(ii) > 0)
            w_candidates(end+1) = wvals(ii); 
            k_candidates(end+1) = kvals(ii); 
        end
    end
end

%% --- Method 2: Numerical solving (fsolve) if symbolic fails ---
if isempty(w_candidates)
    fprintf('Symbolic method did not yield valid solutions. Using numerical fsolve...\n');

    % Multiple initial guesses
    init_guesses = [1 0.5; 2 1; 6 4; 7 4.2; 5 3];
    opts = optimoptions('fsolve','Display','off','TolFun',1e-12,'TolX',1e-12);

    for ig = 1:size(init_guesses,1)
        x0 = init_guesses(ig,:);
        fun = @(x) my_eqs(x,p1,p2,p3,g); % x = [w; k]

        try
            solx = fsolve(fun, x0, opts);
            wsol = solx(1); 
            ksol = solx(2);

            if isreal(wsol) && wsol>0 && isreal(ksol)
                if isempty(w_candidates) || min(abs(w_candidates - wsol))>1e-6
                    w_candidates(end+1) = wsol; 
                    k_candidates(end+1) = ksol; 
                end
            end
        catch
        end
    end
end

%% --- Output and plot the results ---
if isempty(w_candidates)
    warning('No imaginary-axis crossing found.');
else
    for ii = 1:length(w_candidates)
        w_sol = w_candidates(ii);
        k_sol = k_candidates(ii);

        fprintf('Imaginary-axis crossing found:\n');
        fprintf('  omega = %.10f rad/s\n', w_sol);
        fprintf('  k     = %.12f\n', k_sol);

        % Mark imaginary-axis crossing (j*w and -j*w)
        plot(0, w_sol,  'ko', 'MarkerFaceColor','y');
        plot(0, -w_sol, 'ko', 'MarkerFaceColor','y');

        % Compute closed-loop poles for this k
        a3 = 1;
        a2 = (p1+p2+p3);
        a1 = (p1*p2 + p1*p3 + p2*p3);
        a0 = p1*p2*p3 + k_sol * g;

        cl_p = roots([a3 a2 a1 a0]);

        fprintf('Closed-loop poles at this k:\n');
        disp(cl_p);

        % Plot closed-loop poles
        plot(real(cl_p), imag(cl_p), 'r*', 'MarkerSize', 8);

        % Text labels
        text(0.1,  w_sol, sprintf(' j%.6f (k=%.6f)', w_sol, k_sol), 'Color','k');
        text(0.1, -w_sol, sprintf('-j%.6f', w_sol), 'Color','k');
    end
end

hold off;

%% Helper function for fsolve: real(expr)=0, imag(expr)=0
function F = my_eqs(x,p1,p2,p3,g)
    w = x(1);
    k = x(2);
    s = 1i * w;
    val = (s + p1)*(s + p2)*(s + p3) + k * g;
    F = [ real(val); imag(val) ];
end

