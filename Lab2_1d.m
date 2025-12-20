s = tf('s');
G = (0.3*s+5.4)/(s^3+6*s^2+11*s+6);

Kp = 10;
Ki = 12.7324;
Kd = 1.9635;

C = Kp + Ki/s + Kd*s;
T = feedback(C*G,1);

step(T)
grid on
title('ZN PID Step Response')
