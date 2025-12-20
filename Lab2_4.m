%Q1_d
c = 0.3; b = 18; a1 = 1; a2 = 3; a3 = 2;
num = c*[1 b];
den = conv([1 a1], conv([1 a2], [1 a3]));
G = tf(num, den);

Kc = 50/3;
omega_c = 4;
Tc = 2*pi/omega_c;
kp = 0.6 * Kc;
ki = 1.2 * Kc / Tc;
kd = 0.075 * Kc * Tc;
C = pid(kp, ki, kd);
T1 = feedback(C*G, 1);
step(T1);
%--------------------------------------------------------
%Q2_e
omega_n = 20.35;
ki = omega_n^4 / 5.4;
kd = 7*omega_n - 20;
kp = (2.7*omega_n^3 - 6 - omega_n^4/18) / 5.4;
C_itae = pid(kp, ki, kd);
T2_no_pre = feedback(C_itae*G, 1);

num_pre = omega_n^4;
den_pre = 0.3 * conv([kd kp ki], [1 18]);
P = tf(num_pre, den_pre);
T2 = P * T2_no_pre;
step(T2);
%---------------------------------------------------------
%Q3_d
A = [0 1 0; 0 0 1; -6 -11 -6];
B = [0; 0; 1];
C = [5.4 0.3 0];
D = 0;
sys = ss(A, B, C, D);

K = [994, 289, 24];
Nx = [1/5.4; 0; 0];
Nu = 1000/5.4;

Acl = A - B*K;
Bcl = B*Nu;
Ccl = C;
Dcl = 0;
sys_cl = ss(Acl, Bcl, Ccl, Dcl);
step(sys_cl);
%-----------------------------------------------------------
%Q4

figure;
step(T1, 'r', T2, 'g', sys_cl, 'b');
legend('Ziegler-Nichols PID', 'ITAE PID with prefilter', 'State feedback with feedforward');
title('Step responses comparison');