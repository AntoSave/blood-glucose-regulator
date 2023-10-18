%S = stepinfo(sys) % where sys is dynamic system model
K = [-1651800 2200];
kr = -1636751;
sim('WP1_sym.slx')
t = ans.t
t = t.Time
y = ans.y

% t = out.t
% t = t.Time
% y = out.y

yfinal = 0.0451
S1 = stepinfo(y,t,yfinal)

% Dalla documentazione è il settling time di default è al 2%

% sys = tf([1 5 5],[1 1.65 5 6.5 2]); % Transfer function
% S1 = stepinfo(sys,'SettlingTimeThreshold',0.005); % set SettlingTimeThreshold to 0.5%, or 0.005
% st1 = S1.SettlingTime;
% S2 = stepinfo(sys,'RiseTimeThreshold',[0.05 0.95]); %set RiseTimeThreshold to a vector containing those bounds



