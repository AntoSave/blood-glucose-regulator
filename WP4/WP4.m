clear all, clc;
%% Progettare un controllore feedback linearization
syms alpha beta
assume(alpha<0)
assume(beta<0)

charpoly = [1 -alpha -beta];
%settling = 4/omega0
%rise time = 2.7/omega0
zita = 1;
settling_time=1;
omega_n = 4.0/settling_time;

des_poly = [1 2*zita*omega_n omega_n^2];

sol = solve(charpoly == des_poly, [alpha, beta]);

alpha = double(sol.alpha);
beta = double(sol.beta);