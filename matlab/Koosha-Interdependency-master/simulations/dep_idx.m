function indices = dep_idx(d, np)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function calculates dependency indices introduced in my paper titled
% "Quantification and Analysis of Interdependency in Cyber-Physical
% Systems," namely, total influence matrix (t), in-degree (nu),
% out-degree(tau), and system/subsystem dependency index (gamma).
% INPUTS:
%  -d: Direct influence matrix
%  -np: Number of physical components (only needed if the system is a CPS)
% OUTPUT:
%  -indices: A structure with the following fields:
%       'd': Direct influence matrix (same as the input with diagonal
%       elements set to zero.
%       'dt': Normalized direct influence matrix
%       't': Total influence matrix
%       'tau': Out-degree
%       'nu': In-degree
%       --------------------------
%       ONLY FOR PHYSICAL SYSTEMS:
%       --------------------------
%       'gamma': System dependency index
%       --------------
%       ONLY FOR CPSs:
%       --------------
%       'gamma.phyphy': Physical-physical
%       'gamma.phycy': Physical-cyber
%       'gamma.cyphy': cyber-physical
%       'gamma.cycy': Cyber-cyber
%       'gamma.total': System dependency index
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     March 4, 2014
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = size(d, 1);
for i = 1 : n
    d(i, i) = 0;
end
dt = d / max(sum(d, 2));
beta = 1;
t =  nthroot((dt / (eye(n) - dt)), beta);

for i = 1 : n
    for j = 1 : n
        if i == j
            t(i, j) = ((n+1) / (n-1)) * t(i, j);
        else
            t(i, j) = ((n+1) / n) * t(i, j);
        end
    end
end
tau = sum(t, 2) / n;
nu = sum(t, 1) / n;

gamma = (1 / (n^2)) * sum(t(:));

indices.d = d;
indices.dt = dt;
indices.t = t;
indices.tau = tau;
indices.nu = nu;
if nargin == 2
    nc = n - np;
    indices.gamma.phyphy = (1 / (np * np)) * sum(sum(t(1:np, 1:np)));
    indices.gamma.phycy = (1 / (np * nc)) * sum(sum(t(1:np, np+1:end)));
    indices.gamma.cyphy = (1 / (nc * np)) * sum(sum(t(np+1:end, 1:np)));
    indices.gamma.cycy = (1 / (nc * nc)) * sum(sum(t(np+1:end, np+1:end)));
    indices.gamma.total = gamma;
else
    indices.gamma = gamma;
end
    

end
