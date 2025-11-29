%% Part (f) FINAL – No analytic method, two responses in one figure (subplot)
clear; close all; clc;

%% Parameters
g = 121; p1 = 4; p2 = 3; p3 = 5;
PO_target = 0.10;

%% Open-loop transfer function
num_open = g;
den_open = conv(conv([1 p1],[1 p2]), [1 p3]);
L0 = tf(num_open, den_open);

%% ---------- (1) Find k_max from Routh ----------
k_max = 504 / g;
fprintf("k_max = %.12f\n", k_max);

%% ---------- (2) Compute k_final that gives REAL 10%% overshoot for full 3rd-order system ----------
% function for computing true overshoot
computePO = @(k) true_PO(k, L0);

% bracket search
kl = 0;                      % PO small at small k
kh = min(0.6, k_max*0.99);   % starting guess

PO_kl = computePO(kl);
PO_kh = computePO(kh);

while PO_kh < PO_target*100 && kh < 0.99*k_max
    kh = kh + 0.05*(k_max - kh);
    PO_kh = computePO(kh);
end

fprintf("Bracket: kl=%.6f (PO=%.2f%%), kh=%.6f (PO=%.2f%%)\n", ...
    kl, PO_kl, kh, PO_kh);

% bisection
for it = 1:60
    k_mid = (kl + kh)/2;
    PO_mid = computePO(k_mid);

    if PO_mid > PO_target*100
        kh = k_mid;
    else
        kl = k_mid;
    end
end

k_final = (kl + kh)/2;
PO_final = computePO(k_final);

fprintf("k_final = %.12f, PO_final = %.4f%%\n", k_final, PO_final);

%% ---------- (3) Closed-loop systems ----------
CL_kmax = feedback(k_max * L0, 1);
CL_kfinal = feedback(k_final * L0, 1);

p_kmax = pole(CL_kmax);
p_kfinal = pole(CL_kfinal);

fprintf("\nPoles for k_max:\n"); disp(p_kmax);
fprintf("Poles for k_final:\n"); disp(p_kfinal);

%% ---------- (4) Stepinfo ----------
% k_max: simulate from 0–10 s
t1 = 0:0.001:10;
[y1, t1] = step(CL_kmax, t1);

% k_final: long simulation
t2 = 0:0.0001:5;
[y2, t2] = step(CL_kfinal, t2);
yss2 = mean(y2(end-300:end));
info_final = stepinfo(y2, t2, yss2);

fprintf("\nStepinfo for k_final:\n");
disp(info_final);

%% ---------- (5) Plot: BOTH graphs in ONE FIGURE (subplot) ----------
figure;

%% subplot 1 — k_max (0–10 s)
subplot(2,1,1);
plot(t1, y1, 'LineWidth', 1.7); grid on;
title(sprintf("Step response for k_{max} = %.6f (0–10 s)", k_max));
xlabel("Time (s)"); ylabel("Response");

% Annotate poles
str1 = sprintf("Poles of k_{max}:\n%.3f%+.3fi\n%.3f%+.3fi\n%.3f%+.3fi", ...
    real(p_kmax(1)), imag(p_kmax(1)), ...
    real(p_kmax(2)), imag(p_kmax(2)), ...
    real(p_kmax(3)), imag(p_kmax(3)));
text(0.65*max(t1), 0.75*max(y1), str1, 'BackgroundColor','w');

% Add note about stability
if any(real(p_kmax) >= 0)
    text(0.05*10, 0.9*max(y1), "Nearly marginal / oscillatory", "BackgroundColor","y");
end

%% subplot 2 — k_final (PO = 10%)
subplot(2,1,2);
plot(t2, y2, 'LineWidth', 1.7); grid on;
title(sprintf("Step response for k_{10%%} = %.6f (PO ≈ %.2f%%)", k_final, PO_final));
xlabel("Time (s)"); ylabel("Response");

legend(sprintf("PO=%.2f%%, Ts=%.3fs, Tp=%.3fs", ...
    info_final.Overshoot, info_final.SettlingTime, info_final.PeakTime), ...
    'Location','Best');

% annotate poles
str2 = sprintf("Poles of k_{10%%}:\n%.3f%+.3fi\n%.3f%+.3fi\n%.3f%+.3fi", ...
    real(p_kfinal(1)), imag(p_kfinal(1)), ...
    real(p_kfinal(2)), imag(p_kfinal(2)), ...
    real(p_kfinal(3)), imag(p_kfinal(3)));
text(0.05*max(t2), 0.7*max(y2), str2, 'BackgroundColor','w');

%% -------- function: true PO --------
function PO = true_PO(k, L0)
    CL = feedback(k * L0, 1);
    p = pole(CL);
    if any(real(p) >= 0)
        PO = 1e6;  % unstable → reject
        return;
    end
    t = 0:0.001:10;
    y = step(CL, t);
    yss = mean(y(end-200:end));
    PO = (max(y) - yss) / yss * 100;
end
