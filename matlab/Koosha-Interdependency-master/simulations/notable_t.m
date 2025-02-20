function notable_t(file_name)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function finds component pairs with large total influence but small
% direct influence.
% INPUTS:
%  -file_name: Name of the input system
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     February 13, 2017
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Headers
DATA_PATH = 'data';
LIB_PATH = 'lib';
addpath(LIB_PATH);
D_PATH = 'd';

%% Read number of components in each category
load(fullfile(DATA_PATH, [file_name, '_comps.mat']))

%% Component names
fields = fieldnames(comps);
comp_type = [];
n = 0;
for i = 1 : numel(fields)
    comps.(fields{i}).start_idx = n; % Index for accessing the first
    % element of each category of components
    n = n + comps.(fields{i}).n;
    comp_type = [comp_type; repmat(fields(i), comps.(fields{i}).n, 1)];
end
idx = zeros(n, 1);
for i = 1 : n
    for j = 1 : numel(fields)
        if i > comps.(fields{j}).start_idx && ...
                i <= comps.(fields{j}).start_idx + comps.(fields{j}).n
            idx(i) = i - comps.(fields{j}).start_idx;
            break
        end
    end
end
for i = 1 : n
    node_names{i} = comp_name(file_name, comp_type{i}, idx(i), false);
end
[~, idx_last, idx] = unique(node_names(:));
duplicates = setdiff(idx, idx_last);
for i = 1 : numel(duplicates)
    node_names{duplicates(i)} = [node_names{duplicates(i)} '*'];
end

%% Import d matrix if exists, calculate and save otherwise
if exist(fullfile(D_PATH, [file_name, '.mat']), 'file') ~= 2
    load(fullfile(DATA_PATH, [file_name, '_comps.mat']))
    disp('Extracting D using PCC method...')
    d_cor = identify_dep(comps, file_name, 'cor');
    disp('Extracting D using RDC method...')
    d_rdc = identify_dep(comps, file_name, 'rdc');
    disp('Extracting D using causation method...')
    d_qis = identify_dep(comps, file_name, 'qis');
    save(fullfile(D_PATH, [file_name, '.mat']), 'd_cor', 'd_rdc', 'd_qis');
else
    load(fullfile(D_PATH, [file_name, '.mat']))
end

%% Calculate t, compare with d, and print notable component pairs
dep_cor = dep_idx(d_cor);
t_norm = dep_cor.t ./ max(dep_cor.t(:));
d_norm = dep_cor.d ./ max(dep_cor.d(:));
[~, si] = sort(t_norm(:) - d_norm(:), 'descend');
[r_cor, c_cor] = ind2sub(size(t_norm), si);
dep_rdc = dep_idx(d_rdc);
t_norm = dep_rdc.t ./ max(dep_rdc.t(:));
d_norm = dep_rdc.d ./ max(dep_rdc.d(:));
[~, si] = sort(t_norm(:) - d_norm(:), 'descend');
[r_rdc, c_rdc] = ind2sub(size(t_norm), si);
dep_qis = dep_idx(d_qis);
t_norm = dep_qis.t ./ max(dep_qis.t(:));
d_norm = dep_qis.d ./ max(dep_qis.d(:));
[~, si] = sort(t_norm(:) - d_norm(:), 'descend');
[r_qis, c_qis] = ind2sub(size(t_norm), si);

fprintf('\tPCC\t\t\t\tRDC\t\t\t\t\tCausation\n')
for i = 1 : 15
    fprintf('%6s - %6s\t\t%6s - %6s\t\t%6s - %6s\n', ...
        node_names{r_cor(i)}, ...
        node_names{c_cor(i)}, ...
        node_names{r_rdc(i)}, ...
        node_names{c_rdc(i)}, ...
        node_names{r_qis(i)}, ...
        node_names{c_qis(i)})
end

%% Clean
rmpath('lib')