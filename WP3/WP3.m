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
x1_eq = x_eq(1);
x2_eq = x_eq(2);
% Il K è il risultato del WP2
K = [-49.7747 99.1105];
A = [-p1-x_eq(2) -x_eq(1); 0 -p2];
B = [0; p3];
C = [1 0];
D = [0];

%% Osservatore
% matrice di osservabilità
W0 = [C;C*A];
rank(W0); 

% matrice di osservabilità in forma canonica
syms x
polyA = charpoly(A,x)
polyA = coeffs(polyA)
a1 = polyA(2);
a2 = polyA(1);
W0_tilde = inv([1,0;a1,1]); %in alternativa W0_tilde = [1 0;-a1 1];

% calcolo dei coefficienti del polinomio desiderato
Sett_time = 1;
w0 = 4.0/Sett_time;
zeta = 1;
pd1 = 2*zeta*w0;
pd2 = w0^2;

L = inv(W0)*W0_tilde*[pd1-a1;pd2-a2];
L = eval(L) 

simout = sim('v1_lqr_observer.slx');
t = simout.t;
t = t.Time;
y = simout.y;
u = simout.u;

x = simout.x

x_hat = simout.x_hat.Data;

%x_tilde = x - x_hat
%stepinfo(x_tilde(:,1),t,0)
%stepinfo(x_tilde(:,2),t,0)

x_hat_1_stepinfo = stepinfo(x_hat(:,1),t,x1_eq) % Tempo di assestamento 12.91
x_hat_2_stepinfo = stepinfo(x_hat(:,2),t,x2_eq) % Tempo di assestamento 6.3369. Overshoot: 394.6826

y_stepinfo = stepinfo(y,t,x1_eq) %Tempo di assestamento di 12.97min e overshoot del 50%
u_stepinfo = stepinfo(u,t,u(end)) %Picco di 122



% Sett_time = 1;
% w0 = 5.6/Sett_time;
% zeta =sqrt(2)/2;
% y_stepinfo = 
%          RiseTime: 1.3623
%     TransientTime: 12.6225
%      SettlingTime: 12.5599
%       SettlingMin: 0.0420
%       SettlingMax: 0.0646
%         Overshoot: 43.2214
%        Undershoot: 0
%              Peak: 0.0646
%          PeakTime: 3.1392
% 
% 
% u_stepinfo = 
%          RiseTime: 0.0029
%     TransientTime: 3.9894
%      SettlingTime: 11.3523
%       SettlingMin: 0.9487
%       SettlingMax: 52.0459
%         Overshoot: 5.1407e+03
%        Undershoot: 2.2374e+04
%              Peak: 222.1965
%          PeakTime: 0.1515





% è possibile controllare che i coefficienti del polinomio caratteristico dell'osservatore siano
% quelli desiderati
syms x
polyObs = charpoly(A-L*C,x);
coeffs_obs = eval(coeffs(polyObs))


%% soluzione con il comando place
% syms x
% polyA = charpoly(A-L*C,x)
% polyA = coeffs(polyA)
% 
% syms s;
% f = s^2+pd1*s+pd2 == 0
% res = solve(f,[s])
% pole1 = eval(res(1));
% pole2 = eval(res(2));
% L_check = place(A.', C.',[pole1 pole2]);
% L_check = L_check.'



%TODO:
%- piazzare meglio i poli dell'osservatore
%- valutare tempo di salita, sovraelongazione ecc della risposta come fatto
% per WP precedenti


