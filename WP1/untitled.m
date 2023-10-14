p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097; %0.0097
ge = 0.97;
ie = 0.003;
u = 1.003;
K = [-1651800 2200];
kr = -1636751;
%u = (p3*ie-p1*p2)/p3
r=0.0451;

%% simbolic solutions
syms x1 x2
eqn1 = -(p1+x2)*x1+p1*ge == 0;
eqn2 = -(p2*x2)+p3*(-K*[x1, x2]+kr*r-ie) == 0;
sol = solve([eqn1, eqn2], [x1, x2]);
double(sol.x1)
double(sol.x2)

%% Plot punti di equilibrio al variare dell'ingresso di controllo

[x1eq,x2eq] = findEquilibrium([-2:0.05:-0.1]);
plot_dir(x1eq.',x2eq.');
hold on
[x1eq,x2eq] = findEquilibrium([0:0.05:2]);
plot_dir(x1eq.',x2eq.');
xlabel("x1")
ylabel("x2")
hold on

[x1eq0,x2eq0] = findEquilibrium(0)
[x1eq1,x2eq1] = findEquilibrium(1.003)
scatter(x1eq0,x2eq0)
text(x1eq0,x2eq0,'u=0')
scatter(x1eq1,x2eq1)
text(x1eq1,x2eq1,'u=1.003')

function [x1eq,x2eq] = findEquilibrium(u)
    p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
    p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
    p3 = 0.0097; %0.0097
    ge = 0.97;
    ie = 0.003;

    x2eq = (p3*(u-ie))/p2;
    x1eq = p1*ge./(p1+x2eq);
end
