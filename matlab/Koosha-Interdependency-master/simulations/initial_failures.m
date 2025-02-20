function cases = initial_failures(nl, nf, np, nd, ml, mf, mp, mc, md)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function generates initial failure cases and is used by other
% functions that simulate failure cases.
% Inputs:
%  -nl: Number of lines
%  -nf: Number of FACTS devices
%  -np: Number of PMU devices
%  -nd: Number of decision suport entities
%  -ml: Maximum number of concurrent line failures
%  -mf: Maximum number of concurrent FACTS failures
%  -mp: Maximum number of concurrent PMU failures
%  -mc: Maximum number of concurrent communication failures
%  -md: Maximum number of concurrent decision support failures
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
LIB_PATH = 'lib';
addpath(LIB_PATH);
INC_PHY_NORM = 0;
INC_CY_NORM = 1;

cases = struct('line', {}, 'facts', {}, 'pmu', {}, 'ds_facts', {}, ...
    'pmu_ds', {}, 'ds', {});
idx = 0;

for cl = double(~INC_PHY_NORM) : ml
    for cf = double(~INC_CY_NORM) : mf
        for cp = double(~INC_CY_NORM) : mp
            for cc = double(~INC_CY_NORM) : mc
                for cd = double(~INC_CY_NORM) : md
                    l_comb = nchoosek2(1 : nl, cl);
                    f_comb = nchoosek2(1 : nf, cf);
                    p_comb = nchoosek2(1 : np, cp);
                    c_comb = nchoosek2(1 : np + nf, cc);
                    d_comb = nchoosek2(1 : nd, cd);
                    for xl = 1 : size(l_comb, 1)
                        for xf = 1 : size(f_comb, 1)
                            for xp = 1 : size(p_comb, 1)
                                for xc = 1 : size(c_comb, 1)
                                    for xd = 1 : size(d_comb, 1)
                                        idx = idx + 1;
                                        cases(idx).line = {l_comb(xl, :)};
                                        cases(idx).facts = {f_comb(xf, :)};
                                        cases(idx).pmu = {p_comb(xp, :)};
                                        c_comb_row = c_comb(xc, :);
                                        cases(idx).ds_facts = ...
                                            {c_comb_row(c_comb_row <= nf)};
                                        cases(idx).pmu_ds = ...
                                            {c_comb_row(c_comb_row > nf) ...
                                            - nf};
                                        cases(idx).ds = {d_comb(xd, :)};
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

rmpath(LIB_PATH)