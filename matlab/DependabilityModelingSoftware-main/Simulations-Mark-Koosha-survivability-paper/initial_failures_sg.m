function cases = initial_failures_sg(nl, nf, np, nd, mphy, mcy)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates initial failure cases and is used by other
% functions that simulate failure cases.
% Inputs:
%  -nl: Number of lines
%  -nf: Number of FACTS devices
%  -np: Number of PMU devices
%  -nd: Number of decision suport entities
%  -mp: Number of concurrent failures in physical network (lines and FACTS)
%  -mc: Number of concurrent failures in cyber network
% Output:
%  -failure_cases: An array of structures with following fields: 
%       'line', 'facts', 'pmu', 'ds_facts', 'pmu_ds', and 'ds'
%   where each element represents a failure case and index(ices) inside
%   corresponding fields show the components that are killed in that
%   failure case. For example, a failure case in which lines 3 and 7 and
%   pmu 2 are killed, is represented by a structure whose 'line' field
%   equals {[3, 7]} and 'pmu' field equals {[2]}. Other fields are empty.
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     April 23, 2015
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cases = struct('line', {}, 'facts', {}, 'pmu', {}, 'ds_facts', {}, ...
    'pmu_ds', {}, 'ds', {});
idx = 0;

for i = 1 : mphy
    for j = 1 : mcy
        phy_comb = nchoosek(1 : nl + nf, i);
        cy_comb = nchoosek(1 : np + nf + np + nd, j);
        for k = 1 : size(phy_comb, 1)
            for l = 1 : size(cy_comb, 1)
                phy_comb_row = phy_comb(k, :);
                cy_comb_row = cy_comb(l, :);
                idx = idx + 1;
                cases(idx).line = {phy_comb_row( ...
                    1 <= phy_comb_row & ...
                    phy_comb_row <= nl)};
                cases(idx).facts = {phy_comb_row( ...
                    nl + 1 <= phy_comb_row & ...
                    phy_comb_row <= nl + nf) ...
                    - nl};
                cases(idx).pmu = {cy_comb_row( ...
                    1 <= cy_comb_row & ...
                    cy_comb_row <= np)};
                cases(idx).ds_facts = {cy_comb_row( ...
                    np + 1 <= cy_comb_row & ...
                    cy_comb_row <= np + nf) ...
                    - np};
                cases(idx).pmu_ds = {cy_comb_row( ...
                    np + nf + 1 <= cy_comb_row & ...
                    cy_comb_row <= np + nf + np) ...
                    - np - nf};
                cases(idx).ds = {cy_comb_row( ...
                    np + nf + np + 1 <= cy_comb_row & ...
                    cy_comb_row <= np + nf + np + nd) ...
                    - np - nf - np};
            end
        end
    end
end