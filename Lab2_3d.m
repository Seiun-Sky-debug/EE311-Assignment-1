% State space model
A = [0 1 0; 0 0 1; -6 -11 -6];
B = [0; 0; 1];
C = [5.4 0.3 0];
D = 0;
sys = ss(A, B, C, D);

% State feedback gain
K = [994, 289, 24];
Nx = [1/5.4; 0; 0];
Nu = 1000/5.4;

% Closed-Loop system
Acl = A - B*K;
Bcl = B*Nu;
Ccl = C;
Dcl = 0;
sys_cl = ss(Acl, Bcl, Ccl, Dcl);
step(sys_cl);