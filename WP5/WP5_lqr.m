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

%% Controllore LQR e sigma=r (sigma=x1)
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
B = double(J_B);
C = [1 0];
D=0;

sigma = [0.01:0.02:2];
K_sigma = [];

for i = sigma
    temp_A = double(subs(A,{'sigma'},i));
    sys = ss(temp_A,B,C,D);
    Qu = 1e-4;
    Qx = [10 0;0 0.1];
    [K,S,P] = lqr(sys, Qx, Qu);
    K_sigma = [K_sigma, K.'];
end
% K_sigma contiene su ogni riga j il valore associato a sigma(j). La
% prima riga contiene k1 e la seconda k2.



