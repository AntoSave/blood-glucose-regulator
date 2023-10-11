%% Analisi del sistema a ciclo aperto
p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq = 1.003;

%Punto di equilibrio per u=1.003
[x1_eq,x2_eq] = findEquilibrium(u_eq);

%Linearizzazione attorno al punto di equilibrio
A = [-p1 -x2_eq; 0 -p2];
B = [0; p3];
C = [x1_eq 0];

%Gli autovalori della matrice dinamica sono
[V,D] = eig(A);
%The eigenvalues of the dynamic matrix are
D(0, 0)

%% Analisi del controllore state feedback
K = [-1651800 2200];
kr = -1636751;

% La nuova posizione degli autovalori è


%sim('WP1_sym.slx')

function [x1eq,x2eq] = findEquilibrium(u)
    p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
    p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
    p3 = 0.0097; %0.0097
    ge = 0.97;
    ie = 0.003;

    x2eq = (p3*(u-ie))/p2;
    x1eq = p1*ge./(p1+x2eq);
end