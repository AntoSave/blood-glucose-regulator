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

%% Individuazione dei Trim Points
% syms kr x1 x2 r
% eqn1 = -(p1+x2)*x1+p1*ge == 0;
% eqn2 = -(p2*x2)+p3*(-K*[x1, x2].'+kr*r-ie) == 0;
eq1 = 1/psi*(u-c*sqrt(x));
eq2 = x-sigma;
sol = solve([eq1==0, eq2==0],[u, x]);
x_e=sol.x
u_e=sol.u

%% Linearizzazione intorno ai trim point
syms Ki Kp;
eq1=1/psi*(-Kp*(x-sigma)-Ki*z-c*sqrt(x));
eq2=x-sigma;

J_a=jacobian([eq1, eq2],[x, z])
J_b=jacobian([eq1, eq2], sigma)

A=subs(J_a,'x',x_e)
B=subs(J_b,'u',u_e)


%% Sintesi dei controllori per ogni trim point
% calcoliamo il polinomio caratteristico 
pol=[1, -trace(A), det(A)]

Tr=1;
w0=2.7/Tr;
zeta=0.9;
pol_d=[1 2*zeta*w0 w0^2];
gains=solve(pol==pol_d, [Kp Ki]);

% assunzione
gains.Kp=2*zeta*w0*psi

% sintesi controllori
psi=0.1*sigma^2+1
r=[0:0.2:2];
Kp_sigma=[];
Ki_sigma=[];

for i=r
    Kp_sigma=[Kp_sigma, double(subs(gains.Kp, 'psi', double(subs(psi, 'sigma', i))))];
    Ki_sigma=[Ki_sigma, double(subs(gains.Ki, 'psi', double(subs(psi, 'sigma', i))))];
end

vpa(Kp_sigma)
vpa(Ki_sigma)

%% Simulazione
standard_model='Lezione4_1.sls';

