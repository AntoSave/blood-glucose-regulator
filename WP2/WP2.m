clear all, clc;
%x1 concentrazione del glucosio
%x2 concentrazione di insulina nei liquidi interstiziali 

p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq=1.003;

%% Linearizzazione attorno al punto di equilibrio per u=1.003
%Punto di equilibrio per u=1.003
[x1_eq, x2_eq] = get_equilibrium(u_eq);
%Linearizzazione attorno al punto di equilibrio
A = [-p1-x2_eq -x1_eq; 0 -p2];
B = [0; p3];
C = [1 0];
D = [0];

%% Progettazione v1 con LQR
% Abbiamo scelto di utilizzare LQR perché, oltre a cancellare le
% oscillazioni, il nostro obiettivo è quello di ridurre lo sforzo di
% controllo.

x_eq = [x1_eq; x2_eq];
sys = ss(A,B,C,D);
WR = [B A*B]
rank(WR) %il sistema è raggiungibile.
Qu = 0.00001; %0.0001;
Qx = [1 0;0 0];
K = lqr(sys, Qx, Qu);
%L'LQR stabilizza il sistema linearizzato attorno a (0,0).
%La legge di controllo per il sistema originale sarà u=-K(x-x_eq)+u_eq


simout = sim('v1_lqr.slx');
t = simout.t;
t = t.Time;
y = simout.y;
u = simout.u;
y_stepinfo = stepinfo(y,t,x1_eq) %Tempo di assestamento di 10.6min e overshoot del 0%
u_stepinfo = stepinfo(u,t,u(end)) %Picco di 28.5
min(u)

% y_stepinfo = 
%          RiseTime: 5.8766
%     TransientTime: 10.6519
%      SettlingTime: 10.5901
%       SettlingMin: 0.0407
%       SettlingMax: 0.0450
%         Overshoot: 0
%        Undershoot: 0
%              Peak: 0.0450
%          PeakTime: 20
% 
% u_stepinfo = 
%          RiseTime: 0
%     TransientTime: 4.4558
%      SettlingTime: 10.9631
%       SettlingMin: 1.0038
%       SettlingMax: 28.5332
%         Overshoot: 2.7425e+03
%        Undershoot: 0
%              Peak: 28.5332
%          PeakTime: 0

%% Progettazione v1 con pole placement
syms zita omega_n k1 k2
K = [k1 k2];
zita=1;
ts=7.5;
omega_n = 4/ts;
charpol = charpoly(A-B*K);
desired_pol = [1, 2*zita*omega_n, omega_n^2];
sol = solve(charpol == desired_pol, [k1, k2], ReturnConditions=true)
K = [double(sol.k1) double(sol.k2)];
simout = sim('v1_pole_placement.slx');
t = simout.t;
t = t.Time;
y = simout.y;
u = simout.u;
y_stepinfo = stepinfo(y,t,x1_eq)
u_stepinfo = stepinfo(u,t,u(end))
min(u)

%% Progettazione v1 con azione integrale + pole placement
% Adesso devo verificare la raggiungibilità per il sistema esteso
% estendiamo sia lo stato che l'ingresso per studiare la raggiungibilità
% del nuovo sistema
%Atilde = [A [0 0].'; C 0]
%Btilde = [B [0 0].'; 0 -1]

%Matrice di raggiungibilità
%WR = [Btilde Atilde*Btilde Atilde^2*Btilde];
%rank(WR) %il sistema è raggiungibile perché W_R ha rango massimo. Posso sintetizzare il controllore

%Adesso dobbiamo tarare K e Kr
%K = place(Atilde, [B; 0], [-10 -15 -20]);

