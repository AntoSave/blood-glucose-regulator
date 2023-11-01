% Laboratorio sul Gain scheduling 
clear all 
clc

%x1 concentrazione del glucosio
%x2 concentrazione di insulina nei liquidi interstiziali 

p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq=1.003;

%% Sistema senza controllore linearizzato



%% Individuazione dei Trim Points
% Scelgo sigma=r e come controllore lo state feedback

% syms kr x1 x2 sigma k1 k2
% dx1 = -(p1+x2)*x1+p1*ge;
% dx2 = -(p2*x2)+p3*(-[k1 k2]*[x1, x2].'+kr*sigma-ie);
% 
% sol = solve([dx1==0, dx2==0],[x1, x2]);
% x1_e=sol.x1
% u2_e=sol.x2

%% Scelgo sigma=r e come controllore il PI
% syms kp ki x1 x2 sigma z
% dx1 = -(p1+x2)*x1+p1*ge;
% dx2 = -(p2*x2)+p3*(kp*(x1-sigma)+ki*z-ie);
% dz = x1-sigma;      % Sarebbe dz=y-r, ma ho già sostituito
% 
% sol = solve([dx1==0, dx2==0, dz==0],[x1, x2, z]);
% x1_eq=sol.x1
% x2_eq=sol.x2
% z_eq=sol.z

%% Sistema con solo P e verificare se è controllabile vedendo la matrice dinamica A se ha abbastanza gradi di libertà
syms kp x1 x2 sigma
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(kp*(sigma-x1)-ie);

sol = solve([dx1==0, dx2==0],[x1, x2],"ReturnConditions",true) % Ottengo due soluzioni -> due punti di equilibrio
x1_eq=sol.x1
x2_eq=sol.x2


%% Linearizzazione intorno ai trim point
% J_a=jacobian([dx1, dx2, dz],[x1, x2, z])
% J_b=jacobian([dx1, dx2, dz], sigma)
% 
% A=subs(J_a,{'x1','x2'}, [x1_eq, x2_eq])
% B=subs(J_b, 'z', z_eq) % Inutile ????

J_a=jacobian([dx1, dx2],[x1, x2])
J_b=jacobian([dx1, dx2], sigma)

A=subs(J_a,{'x1','x2'}, [x1_eq(2), x2_eq(2)]) % Vado a sostituire con il primo punto di eq.

% A=subs(J_a,'x1', x1_eq)
% A=subs(A, 'x2', x2_eq)
% B=subs(J_b, 'z', z_eq) % Inutile ????

%% Sintesi dei controllori per ogni trim point
% calcoliamo il polinomio caratteristico 
% pol=[1, -trace(A), det(A)]
% 
% Tr=1;
% w0=2.7/Tr;
% zeta=0.9;
% pol_d=[1 2*zeta*w0 w0^2];
% gains=solve(pol==pol_d, [kp ki]);

%% Metodo antonio
syms zita omega_n
charpol = charpoly(A);

desired_pol = [1, 2*zita*omega_n, omega_n^2];
sol = solve(charpol == desired_pol, kp, ReturnConditions=true)

%sol contiene i guadagni parametrizzati in zita e omega_n
zita = 1;
ts = 10; % 10 minuti
omega_n = 5.8/ts;

% omega_n = 5.8/ts;
% ki = simplify(subs(sol.ki,{'omega_n'},[omega_n]))
kp = subs(sol,{'omega_n','zita'},[omega_n, zita])

%% Creiamo la tabella di scheduling
r= 0.0451;
Kp_sigma=double(subs(kp.kp, 'sigma', r));

% r=[0:0.2:2];
% Kp_sigma=[];
% Kp_sigma=[Kp_sigma, double(subs(kp.kp, 'sigma', r))];

% for i=r
%     Kp_sigma=[Kp_sigma, double(subs(kp, 'sigma', i))];
% end

%% Simulazione
%% TODO: Simulare con il sistema linearizzato per vedere se funzia
syms u x1 x2
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(u-ie);
% 
% sol = solve([dx1==0 dx2==0 u==0],[x1 x2], "ReturnConditions",true)

A_lin = jacobian([dx1 dx2],[x1 x2])
B_lin = jacobian([dx1 dx2],[u])
C_lin = [1 0]
D_lin = 0

x1_eq = subs(x1_eq(2),{'sigma','kp'},[r, Kp_sigma])
x2_eq = subs(x2_eq(2),{'sigma','kp'},[r, Kp_sigma])

x1_eq = double(x1_eq)
x2_eq = double(x2_eq)

A_lin = subs(A_lin,{'x1','x2'},[x1_eq, x2_eq])
A_lin = double(A_lin)
B_lin = double(B_lin)