%x1 concentrazione del glucosio
%x2 concentrazione di insulina nei liquidi interstiziali 

p1 = 0.0151; %tasso base di rimozione del glucosio dal sangue
p2 = 0.0313; %tasso rimozione del glucosio dovuto all'insulina
p3 = 0.0097;
ge = 0.97;
ie = 0.003;
u_eq = 1.003;

%% Analisi del sistema a ciclo aperto
% Plot dei punti di equilibrio al variare di u
[x1eq,x2eq] = get_equilibrium([-2:0.01:-0.1]);
directedplot(x1eq.',x2eq.');
hold on
[x1eq,x2eq] = get_equilibrium([0:0.01:2]);
directedplot(x1eq.',x2eq.');
xlabel("x1")
ylabel("x2")
hold on
% Plot dei punti notevoli u=0 e u=1.003
[x1eq0,x2eq0] = get_equilibrium(0)
[x1eq1,x2eq1] = get_equilibrium(1.003)
scatter(x1eq0,x2eq0)
text(x1eq0,x2eq0,'u=0')
scatter(x1eq1,x2eq1)
text(x1eq1,x2eq1,'u=1.003')

% Piano delle fasi per u=1.003
matlab.apputil.run('PhasePlane')

%Simulazione del sistema a ciclo aperto per u=1.003
tspan = [0 250];
x0=[0 0];
u=1.003;
[t,x] = ode45(@(t,x) SYS([x.' u]), tspan, x0);
x1=x(:,1);
x2=x(:,2);

plot(t,x1,'r',t,x2,'b');
xlabel('t')
figure
plot(x1,x2,'r', 0, 0, 'd')
xlabel('x1')
ylabel('x2')
xlim([-2 2.5])
ylim([-0.5, 0.5])

%% Linearizzazione attorno al punto di equilibrio per u=1.003
%Punto di equilibrio per u=1.003
[x1_eq,x2_eq] = get_equilibrium(u_eq);
x1_eq,x2_eq
%Linearizzazione attorno al punto di equilibrio
A = [-p1-x2_eq -x1_eq; 0 -p2];
B = [0; p3];
C = [1 0];

%Gli autovalori della matrice dinamica sono
[V,D] = eig(A);
lambda1 = D(1,1)
lambda2 = D(2,2)
%Gli autovalori sono entrambi a parte reale negativa allora il punto di
%equilibrio è asintoticamente stabile

%% Analisi del controllore v0 sul sistema linearizzato
K = [-1651800 2200];
kr = -1636751;

% Gli autovalori del sistema retroazionato sono
[V,D] = eig(A-B*K);
lambda1 = D(1,1)
lambda2 = D(2,2)
% Quindi il sistema a ciclo chiuso è asintoticamente stabile ma la presenza
% di una parte immaginaria comporta la presenza di
% sovraelongazioni/oscillazioni.
syms s
c_poly = sym2poly((s-lambda1)*(s-lambda2)); %The characteristic polynomial of A-BK
omega_c = sqrt(c_poly(3))
zita = c_poly(2)/(omega_c*2)
% Simulazione del sistema linearizzato a ciclo chiuso:
t=[0:0.1:1000];
y = step(ss(A-B*K,B.*kr,C,0),t);
plot(t,y)

%% Analisi del controllore v0 sul sistema non lineare
% Piano delle fasi a cilo chiuso per r=0.0451
matlab.apputil.run('PhasePlane')

% Adesso simuliamo il controllore v0
sim('WP1_sym.slx')

%% DA CANCELLARE
% Quindi il sistema a ciclo chiuso è asintoticamente stabile ma la presenza
% di una parte immaginaria comporta la presenza di
% sovraelongazioni/oscillazioni.
%syms s
%c_poly = sym2poly((s-lambda1)*(s-lambda2)); %The characteristic polynomial of A-BK
%omega_c = sqrt(c_poly(3))
%zita = c_poly(2)/(omega_c*2)