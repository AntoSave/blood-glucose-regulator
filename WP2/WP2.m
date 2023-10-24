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
x1_eq, x2_eq = get_equilibrium(u_eq);
%Linearizzazione attorno al punto di equilibrio
A = [-p1-x2_eq -x1_eq; 0 -p2];
B = [0; p3];
C = [1 0];
D = [0];

%% Progettazione v1 con LQR
x_eq = [x1_eq; x2_eq];
sys = ss(A,B,C,D);
WR = [B A*B]
rank(WR) %il sistema è raggiungibile.
Qu = 0.001;
Qx = [10 0;0 1];
K = lqr(sys, Qx, Qu);
%L'LQR stabilizza il sistema linearizzato attorno a (0,0).
%La legge di controllo per il sistema originale sarà u=-K(x-x_eq)+u_eq


%% Progettazione v1 con azione integrale + pole placement
% Adesso devo verificare la raggiungibilità per il sistema esteso
% estendiamo sia lo stato che l'ingresso per studiare la raggiungibilità
% del nuovo sistema
Atilde = [A [0 0].'; C 0]
Btilde = [B [0 0].'; 0 -1]

%Matrice di raggiungibilità
WR = [Btilde Atilde*Btilde Atilde^2*Btilde];
rank(WR) %il sistema è raggiungibile perché W_R ha rango massimo. Posso sintetizzare il controllore

%Adesso dobbiamo tarare K e Kr
K = place(Atilde, [B; 0], [-10 -15 -20]);



%% Progettazione v1 con LQR















% K = place(A,B,[-1 -2]);
% syms kr x1 x2 r
% eqn1 = -(p1+x2)*x1+p1*ge == 0;
% eqn2 = -(p2*x2)+p3*(-K*[x1, x2].'+kr*r-ie) == 0;
% eqn3 = x1 == r;
% eqn4 = r == 0.0451;
% solve([eqn1, eqn2, eqn3, eqn4], kr,x1,x2,r)
% kr=-67679051051420421758406738455527521857/97697717869106025718365625318899712;

