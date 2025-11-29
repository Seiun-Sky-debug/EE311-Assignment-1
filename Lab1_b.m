clear all; close all; clc;

% System parameters
g = 121; p1 = 4; p2 = 3; p3 = 5;
Gp = tf(g, conv([1 p1], [1 p2]));
H = tf(1, [1 p3]);
G_open = Gp * H;

k = 1;
G_open_k = k * G_open;

% Generate frequency vector
w = logspace(-1, 2, 10000);

% Calculate frequency response
[re, im] = nyquist(G_open_k, w);
re = squeeze(re);
im = squeeze(im);

% Create figure
figure;
hold on;

% Draw coordinate axes
plot([-3 3], [0 0], 'k-', 'LineWidth', 0.5); % Real axis
plot([0 0], [-3 3], 'k-', 'LineWidth', 0.5); % Imaginary axis

% Plot positive frequency part
plot(re, im, 'b-', 'LineWidth', 1.5);

% Plot negative frequency part (symmetric)
plot(re, -im, 'b--', 'LineWidth', 1.5);

% Mark (-1,0) critical point
plot(-1, 0, 'ro', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'red');

% Find and mark key intersection points
tol = 0.001;

% 1. Intersection with negative real axis (phase crossover frequency)
zero_imag_idx = find(abs(im) < tol & re < 0, 1);
if ~isempty(zero_imag_idx)
    w_real = w(zero_imag_idx);
    gain_real = re(zero_imag_idx);
    
    % Mark positive frequency side intersection
    plot(gain_real, 0, 'gs', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'green');
    text(gain_real, 0.15, sprintf('ω=%.3f\nG=%.3f', w_real, gain_real), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
end

% 2. Intersection with imaginary axis
zero_real_idx = find(abs(re) < tol & abs(im) > 0.1, 1);
if ~isempty(zero_real_idx)
    w_imag = w(zero_real_idx);
    gain_imag = im(zero_real_idx);
    
    % Mark positive frequency side intersection
    plot(0, gain_imag, 'ms', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'magenta');
    text(0.15, gain_imag, sprintf('ω=%.3f\nIm=%.3f', w_imag, gain_imag), ...
         'VerticalAlignment', 'middle', 'FontSize', 8, 'BackgroundColor', 'white');
    
    % Mark negative frequency side intersection (symmetric)
    plot(0, -gain_imag, 'ms', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'magenta');
    text(0.15, -gain_imag, sprintf('ω=%.3f\nIm=%.3f', w_imag, -gain_imag), ...
         'VerticalAlignment', 'middle', 'FontSize', 8, 'BackgroundColor', 'white');
end

% 3. Mark low frequency starting point
w_low = w(1);
[re_low, im_low] = nyquist(G_open_k, w_low);
re_low = squeeze(re_low); im_low = squeeze(im_low);
plot(re_low, im_low, 'c^', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'cyan');
text(re_low, im_low+0.2, sprintf('ω=%.1f', w_low), ...
     'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');

% 4. Mark high frequency ending point
w_high = w(end);
[re_high, im_high] = nyquist(G_open_k, w_high);
re_high = squeeze(re_high); im_high = squeeze(im_high);
plot(re_high, im_high, 'rv', 'MarkerSize', 8, 'LineWidth', 2, 'MarkerFaceColor', 'red');
text(re_high, im_high-0.2, sprintf('ω=%.0f', w_high), ...
     'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');

% Set graph properties
grid on;
axis equal;
xlim([-3, 3]);
ylim([-3, 3]);
xlabel('Real Axis');
ylabel('Imaginary Axis');
title('Nyquist Plot for k=1');

% Mark origin (0,0)
text(0.1, 0.1, '(0,0)', 'FontSize', 8, 'Color', 'black');

% Create legend
legend('Real Axis', 'Imaginary Axis', 'Positive Frequency', 'Negative Frequency', '(-1,0) Critical Point', 'Real Axis Intersection', ...
       'Imaginary Axis Intersection', 'Low Frequency Start', 'High Frequency End', 'Location', 'best');

hold off;

% Calculate maximum stable gain
[GM, PM, wcg, wcp] = margin(G_open_k);
fprintf('Maximum stable gain k_max = %.4f\n', GM);