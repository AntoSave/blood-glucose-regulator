clear all, clc;
%% Progettare un controllore feedback linearization con "metodo analitico"
syms alpha beta
assume(alpha<0)
assume(beta<0)

charpoly = [1 -alpha -beta];
%settling = 4/omega0
%rise time = 2.7/omega0
zita = 1;
settling_time=6;
omega_n = 4.0/settling_time;

des_poly = [1 2*zita*omega_n omega_n^2];

sol = solve(charpoly == des_poly, [alpha, beta]);

alpha = double(sol.alpha);
beta = double(sol.beta);

simout = sim('v2_sim.slx');
y = simout.y;
t = simout.t.Time;
u = simout.u;

y_stepinfo = stepinfo(y,t,y(end))
u_stepinfo = stepinfo(u,t,u(end))

%Questo è buono ma manca la reiezione dei disturbi

%% Progettare un controllore feedback linearization con "metodo analitico" e azione integrale
clear all, clc;
% Estendiamo lo stato del sistema linearizzato per aggiungere l'azione
% integrale. La matrice dinamica a ciclo chiuso del sistema retroazionato è:
syms alpha beta gamma
A = [0 1 0; beta alpha gamma; -1 0 0];
char_poly_coeff = charpoly(A);

syms s zita w_n p
desired_poly = (s^2 + 2*zita*w_n*s + w_n^2)*(s-p);
desired_poly_coeff = fliplr(coeffs(desired_poly, s));

sol = solve(char_poly_coeff==desired_poly_coeff,[alpha, beta, gamma],"ReturnConditions",true);


zita = 1;
settling_time=10;
omega_n = 3;%4.0/settling_time;
p = -5/100;
alpha = double(subs(sol.alpha,{'zita','w_n','p'}, [zita, omega_n, p]));
beta = double(subs(sol.beta,{'zita','w_n','p'}, [zita, omega_n, p]));
gamma = double(subs(sol.gamma,{'zita','w_n','p'}, [zita, omega_n, p]));

simout = sim('v2_sim_integral_action.slx');
y = simout.y;
t = simout.t.Time;
u = simout.u;
y_stepinfo = stepinfo(y,t,y(end))
u_stepinfo = stepinfo(u,t,u(end))

%NON siamo riusciti a tarare decentemente il sistema perché l'azione
%integrale causa forti sottoelongazioni

%% Feedback linearization con PID
%La funzione di trasferimento del sistema da controllare è:
s = tf('s');
P = 1/s^2;
%rltool(P,1);
C = 4.2975*(s+0.191)*(s+0.1311)/(s*(s+3.039));
simout = sim('v2_sim_PID.slx');
y = simout.y;
t = simout.t.Time;
u = simout.u;
y_stepinfo = stepinfo(y,t,y(end))
u_stepinfo = stepinfo(u,t,u(end))
undershoot = (min(y)-y(end))/y(end)

