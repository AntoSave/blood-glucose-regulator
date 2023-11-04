clear all 
clc

p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq=1.003;

%x1 concentrazione del glucosio
%x2 concentrazione di insulina nei liquidi interstiziali 

%% Controllore state feedback e sigma=r (sigma=x1)
%Consideriamo il sistema non lineare
syms x1 x2 u
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(u-ie);

sol = solve([dx1==0, dx2==0],[x1, x2]);

%Poniamo sigma=r.
%Noi vogliamo che y_eq = r -> x1_eq = r = sigma
syms sigma 
sol = solve([x1==sol.x1(1), x2==sol.x2(1), x1==sigma],[x1, x2, u]); %Qui poinamo x1_eq==sigma e troviamo x1_eq, x2_eq e u_eq in funzione di sigma
x1_eq = sol.x1(1);
x2_eq = sol.x2(1);
u_eq = sol.u(1);

% Troviamo le Jacobiane e sostituiamoci le condizioni operative per
% ottenere le matrici del sistema linearizzato
J_A=jacobian([dx1, dx2],[x1, x2]);
J_B=jacobian([dx1, dx2], u);
A = subs(J_A,{'x1','x2'}, [x1_eq, x2_eq]);
B = J_B;
C = [1 0];

%Matrice dinamica a ciclo chiuso
syms k1 k2
K = [k1 k2];
A_CC = A-B*K;

% Equipollenza dei polinomi
syms s zita w_n
pol_coeff=charpoly(A_CC); 
desired_pol=(s^2 + 2*zita*w_n*s + w_n^2);
desired_pol_coeff = fliplr(coeffs(desired_pol, s));

sol = solve(pol_coeff==desired_pol_coeff,[k1, k2],"ReturnConditions",true);


%% Controllore PI e sigma=r
%Consideriamo il sistema non lineare
syms x1 x2 u
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(u-ie);

sol = solve([dx1==0, dx2==0],[x1, x2]);

%Poniamo sigma=r.
%Noi vogliamo che y_eq = r -> x1_eq = r = sigma
syms sigma 
sol = solve([x1==sol.x1(1), x2==sol.x2(1), x1==sigma],[x1, x2, u]); %Qui poinamo x1_eq==sigma e troviamo x1_eq, x2_eq e u_eq in funzione di sigma
x1_eq = sol.x1(1);
x2_eq = sol.x2(1);
u_eq = sol.u(1);

% Troviamo le Jacobiane e sostituiamoci le condizioni operative per
% ottenere le matrici del sistema linearizzato
J_A=jacobian([dx1, dx2],[x1, x2]);
J_B=jacobian([dx1, dx2], u);
A = subs(J_A,{'x1','x2'}, [x1_eq, x2_eq]);
B = J_B;
C = [1 0];

% Progettiamo un PI per il sistema linearizzato
syms kp ki
A_CC = [A-B*kp*C B*ki; C 0]; % Matrice dinamica a ciclo chiuso del sistema linearizzato con controllore

% Equipollenza dei polinomi
syms s zita w_n p
pol_coeff=charpoly(A_CC); 
desired_pol=(s^2 + 2*zita*w_n*s + w_n^2)*(s-p);
desired_pol_coeff = fliplr(coeffs(desired_pol, s));

sol = solve(pol_coeff==desired_pol_coeff,[kp, ki],"ReturnConditions",true);
% Non c'è soluzione perché il secondo coefficiente del poly caratteristico
% non dipende dai parametri del controllore, allora non possiamo imporre una
% dinamica desiderata a ciclo chiuso con un PI, ma per lo meno possiamo
% stabilizzare il sistema. Allora poniamo i coeff > 0
assume(sigma>0);
sol = solve(pol_coeff>[0 0 0 0], [kp, ki],"ReturnConditions",true);
%Risultato: ki>0 kp<0.0473/sigma^2
%Ad esempio scegliamo ki = 1, kp = 0.03/sigma^2


%% Tentativo con controllore P
syms kp x1 x2 sigma
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(kp*(sigma-x1)-ie);

sol = solve([dx1==0, dx2==0],[x1, x2],"ReturnConditions",true) % Ottengo due soluzioni -> due punti di equilibrio
x1_eq=sol.x1
x2_eq=sol.x2

% Linearizzazione intorno ai trim point

J_a=jacobian([dx1, dx2],[x1, x2])
J_b=jacobian([dx1, dx2], sigma)

A=subs(J_a,{'x1','x2'}, [x1_eq(2), x2_eq(2)]) % Vado a sostituire con il primo punto di eq.

% Sintesi dei controllori per ogni trim point
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


% Proviamo un particolare valore di Kp
r= 0.0451;
Kp_sigma=double(subs(kp.kp, 'sigma', r));

% Simulare con il sistema linearizzato per vedere se funziona con quel Kp
syms u x1 x2
dx1 = -(p1+x2)*x1+p1*ge;
dx2 = -(p2*x2)+p3*(u-ie);

A_lin = jacobian([dx1 dx2],[x1 x2]);
B_lin = jacobian([dx1 dx2],[u]);
C_lin = [1 0];
D_lin = 0;

x1_eq = subs(x1_eq(2),{'sigma','kp'},[r, Kp_sigma]);
x2_eq = subs(x2_eq(2),{'sigma','kp'},[r, Kp_sigma]);

x1_eq = double(x1_eq);
x2_eq = double(x2_eq);

A_lin = subs(A_lin,{'x1','x2'},[x1_eq, x2_eq]);
A_lin = double(A_lin);
B_lin = double(B_lin);


%% DA CANCELLARE

% Individuazione dei Trim Points
% Scelgo sigma=r e come controllore lo state feedback

% syms kr x1 x2 sigma k1 k2
% dx1 = -(p1+x2)*x1+p1*ge;
% dx2 = -(p2*x2)+p3*(-[k1 k2]*[x1, x2].'+kr*sigma-ie);
% 
% sol = solve([dx1==0, dx2==0],[x1, x2]);
% x1_e=sol.x1
% u2_e=sol.x2





% calcoliamo il polinomio caratteristico 
% pol=[1, -trace(A), det(A)]
% 
% Tr=1;
% w0=2.7/Tr;
% zeta=0.9;
% pol_d=[1 2*zeta*w0 w0^2];
% gains=solve(pol==pol_d, [kp ki]);


% Creiamo la tabella di scheduling
% r= 0.0451;
% Kp_sigma=double(subs(kp.kp, 'sigma', r));

% r=[0:0.2:2];
% Kp_sigma=[];
% Kp_sigma=[Kp_sigma, double(subs(kp.kp, 'sigma', r))];

% for i=r
%     Kp_sigma=[Kp_sigma, double(subs(kp, 'sigma', i))];
% end
