clear all; close all; clc;

% System parameters
g = 121; p1 = 4; p2 = 3; p3 = 5;
Gp = tf(g, conv([1 p1], [1 p2]));
H = tf(1, [1 p3]);
G_open = Gp * H;

k = 1;
G_open_k = k * G_open;

% Calculate margins first
[GM, PM, wcg, wcp] = margin(G_open_k);
GM_db = 20*log10(GM);

% Create Bode plot with exact annotations
figure;

% Magnitude plot
subplot(2,1,1);
[mag, phase, w] = bode(G_open_k);
mag = squeeze(mag);
mag_db = 20*log10(mag);
semilogx(w, mag_db, 'b-', 'LineWidth', 1.5);
hold on;

% Calculate exact magnitude at phase crossover frequency
mag_at_wcg = abs(evalfr(G_open_k, 1j*wcg));
mag_at_wcg_db = 20*log10(mag_at_wcg);

% Mark phase crossover frequency on magnitude plot using exact calculation
plot(wcg, mag_at_wcg_db, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'red');
plot([wcg, wcg], [min(mag_db), mag_at_wcg_db], 'r--', 'LineWidth', 1);
plot([0.1, wcg], [mag_at_wcg_db, mag_at_wcg_db], 'r--', 'LineWidth', 1);

% Mark gain crossover frequency on magnitude plot
plot(wcp, 0, 'go', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'green');
plot([wcp, wcp], [min(mag_db), 0], 'g--', 'LineWidth', 1);

grid on;
title('Bode Plot with Exact MATLAB Calculations (k=1)');
ylabel('Magnitude (dB)');
xlim([0.1, 100]);

% Add text annotations using exact MATLAB values
text(wcg, mag_at_wcg_db+5, sprintf('ω_{cg}=%.4f rad/s\nGain=%.4f dB', wcg, mag_at_wcg_db), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'white');
text(wcp, 5, sprintf('ω_{cp}=%.4f rad/s', wcp), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'white');

% Indicate gain margin using exact MATLAB value
text(wcg*0.7, (mag_at_wcg_db+0)/2, sprintf('Gain Margin\n%.4f dB\n(Linear: %.4f)', GM_db, GM), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'yellow', 'EdgeColor', 'black');

hold off;

% Phase plot
subplot(2,1,2);
phase = squeeze(phase);
semilogx(w, phase, 'r-', 'LineWidth', 1.5);
hold on;

% Calculate exact phase at crossover frequencies
phase_at_wcg = angle(evalfr(G_open_k, 1j*wcg)) * 180/pi;
phase_at_wcp = angle(evalfr(G_open_k, 1j*wcp)) * 180/pi;

% Mark phase crossover frequency on phase plot
plot(wcg, phase_at_wcg, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'red');
plot([wcg, wcg], [min(phase), phase_at_wcg], 'r--', 'LineWidth', 1);
plot([0.1, wcg], [phase_at_wcg, phase_at_wcg], 'r--', 'LineWidth', 1);

% Mark gain crossover frequency on phase plot
plot(wcp, phase_at_wcp, 'go', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'green');
plot([wcp, wcp], [min(phase), phase_at_wcp], 'g--', 'LineWidth', 1);

% Draw -180° line
plot([0.1, 100], [-180, -180], 'k--', 'LineWidth', 1);

grid on;
ylabel('Phase (degrees)');
xlabel('Frequency (rad/s)');
xlim([0.1, 100]);

% Add text annotations using exact MATLAB values
text(wcg, phase_at_wcg-10, sprintf('Phase at ω_{cg}\n%.4f°', phase_at_wcg), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'white');
text(wcp, phase_at_wcp+10, sprintf('Phase at ω_{cp}\n%.4f°', phase_at_wcp), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'white');

% Indicate phase margin using exact MATLAB value
text(wcp*1.2, (phase_at_wcp-180)/2, sprintf('Phase Margin\n%.4f°', PM), ...
     'HorizontalAlignment', 'center', 'BackgroundColor', 'yellow', 'EdgeColor', 'black');

hold off;

% Display exact values from MATLAB
fprintf('=== Exact MATLAB Calculations ===\n');
fprintf('Gain Margin (linear): GM = %.4f\n', GM);
fprintf('Gain Margin (dB): GM = %.4f dB\n', GM_db);
fprintf('Phase Crossover Frequency: ω_cg = %.4f rad/s\n', wcg);
fprintf('Magnitude at ω_cg: |G(jω_cg)| = %.4f (%.4f dB)\n', mag_at_wcg, mag_at_wcg_db);
fprintf('Phase at ω_cg: ∠G(jω_cg) = %.4f°\n', phase_at_wcg);
fprintf('Phase Margin: PM = %.4f degrees\n', PM);
fprintf('Gain Crossover Frequency: ω_cp = %.4f rad/s\n', wcp);
fprintf('Phase at ω_cp: ∠G(jω_cp) = %.4f°\n', phase_at_wcp);