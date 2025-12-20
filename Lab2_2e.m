% ITAE PID Design
omega_n = 20.35;
ki = omega_n^4 / 5.4;
kd = 7*omega_n - 20;
kp = (2.7*omega_n^3 - 6 - omega_n^4/18) / 5.4;
C_itae = pid(kp, ki, kd);
T2_no_pre = feedback(C_itae*G, 1);

% Pre-filter
num_pre = omega_n^4;
den_pre = 0.3 * conv([kd kp ki], [1 18]);
P = tf(num_pre, den_pre);
T2 = P * T2_no_pre;
step(T2);