clear all, clc;
%x1 concentrazione del glucosio
%x2 concentrazione di insulina nei liquidi interstiziali 

p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq=1.003;
x_eq = [0.0451; 0.3099];

K = [-49.7747 99.1105];
A = [-p1-x_eq(2) -x_eq(1); 0 -p2];
B = [0; p3];
C = [1 0];
D = [0];

%% Osservatore
L = place(A.', C.', [-2, -1]);
L = L.'

%TODO:
%- piazzare meglio i poli dell'osservatore
%- valutare tempo di salita, sovraelongazione ecc della risposta come fatto
% per WP precedenti


