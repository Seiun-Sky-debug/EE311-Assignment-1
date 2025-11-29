g = 121;
p1 = 4;
p2 = 3;
p3 = 5;

OS = 0.10;
zeta = -log(OS) / sqrt(pi^2 + log(OS)^2);

s = tf('s');
Gp = g/((s+p1)*(s+p2));
H = 1/(s+p3);
G_open = Gp * H;

[r,k_values] = rlocus(G_open);

desired_k = 0;
min_error = inf;

for i = 1:length(k_values)
    poles = r(:,i);
    
    complex_poles = poles(imag(poles) ~= 0);
    if ~isempty(complex_poles)
        complex_pole = complex_poles(1);
        wn = abs(complex_pole);
        current_zeta = -real(complex_pole)/wn;
        
        error = abs(current_zeta - zeta);
        if error < min_error
            min_error = error;
            desired_k = k_values(i);
        end
    end
end

fprintf('K = %.4f\n', desired_k);