function d = identify_dep(file_name, method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function analyzes failure sequences of a power grid and extracts its
% direct influence matrix by using one of the three different methods.
% INPUTS:
%  -file_name: Name of the input system
%  -method: Can be one of the following:
%       -'qis': Bsaed on the method introduced in paper titled "An
%               Interaction Model for Simulation and Mitigation of
%               Cascading Failures" by Junjian Qi, Kai Sun, and Shengwei
%               Mei.
%       -'cor': Normalized correlation between flow of one line and flow of
%               another line lagged by one time step. Normalization factor
%               is energy of the two sequences, so its absolute value is
%               guaranteed to be between 0 and 1.
%       -'rdc': Randomized dependence coefficient as introduced in a paper
%               titled "The Randomized Dependence Coefficient" by David
%               Lopez-Paz, Philipp Hennig, and Bernhard Scholkopf.
% OUTPUT:
%  -d: n-by-n direct influence matrix
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     September 23, 2016
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off all
%% Headers
DATA_PATH = 'data';
FAILURE_SEQ_PATH = 'failure_seq';
LIB_PATH = 'lib';
addpath(LIB_PATH);

%% Read number of components in each category
load(fullfile(DATA_PATH, [file_name, '_comps.mat']))

%% Load failure sequence and reformat
load(fullfile(FAILURE_SEQ_PATH, [file_name '.mat']));
fields = fieldnames(comps);
seq_len = length(failure_seq(1).(fields{1}));
n = 0;
for i = 1 : numel(fields)
    comps.(fields{i}).start_idx = n; % Index for accessing the first
    % element of each category of components
    n = n + comps.(fields{i}).n;
end
for i = 1: length(failure_seq)
    failure_seq(i).comp = repmat({[]}, 1, seq_len);
    failure_seq(i).sv.comp = [];
end
for i = 1: length(failure_seq)
    for j = 1 : numel(fields)
        failure_seq(i).sv.comp = [failure_seq(i).sv.comp; ...
            [failure_seq(i).sv.(fields{j}){:}]];
        for k = 1 : seq_len
            failure_seq(i).comp{k} = [failure_seq(i).comp{k}, ...
                failure_seq(i).(fields{j}){k} + ...
                comps.(fields{j}).start_idx];
        end
    end
end

%% Initialize matrices
a = zeros(n); % Immediate failure frequency matrix
ap = zeros(n); % Cause of failure matrix
d = zeros(n); % Direct influence matrix

switch method
    case 'qis'
        %% Generate "a"
        for i = 1 : length(failure_seq)
            for j = 2 : seq_len
                for k = 1 : length(failure_seq(i).comp{j - 1})
                    for l = 1 : length(failure_seq(i).comp{j})
                        a(failure_seq(i).comp{j - 1}(k), ...
                            failure_seq(i).comp{j}(l)) = ...
                            a(failure_seq(i).comp{j - 1}(k), ...
                            failure_seq(i).comp{j}(l)) + 1;
                    end
                end
            end
        end

        %% Calculate "ap"
        for i = 1 : length(failure_seq)
            if length(failure_seq(i).comp) > 1
                for j = 2 : seq_len
                    for k = 1 : length(failure_seq(i).comp{j})
                        maxval = max(a(failure_seq(i).comp{j - 1}, ...
                            failure_seq(i).comp{j}(k)));
                        idx = find(a(failure_seq(i).comp{j - 1}, ...
                            failure_seq(i).comp{j}(k)) == maxval);
                        for l = 1 : length(failure_seq(i).comp{j - 1})
                            if any(idx == l)
                                ap(failure_seq(i).comp{j - 1}(l), ...
                                    failure_seq(i).comp{j}(k)) = ...
                                    ap(failure_seq(i).comp{j - 1}(l), ...
                                    failure_seq(i).comp{j}(k)) + 1;
                            end
                        end
                    end
                end
            end
        end

        %% Calculate "d"
        nf = zeros(n, 1);
        for i = 1 : length(failure_seq)
            for j = 1 : n
                if any([failure_seq(i).comp{:}] == j)
                    nf(j) = nf(j) + 1;
                end
            end
        end
        for i = 1 : n
            if nf(i) > 0
                d(i, :) = ap(i, :) / nf(i);
            end
        end
    case 'cor'
        %% Generate "s"
        % Mapping from components to failure cases in which they are failed
        for i = 1 : n
            s{i} = [];
            for j = 1 : length(failure_seq)
                if any([failure_seq(j).comp{:}] == i)
                    if ~any(s{i} == j)
                        s{i} = [s{i}, j];
                    end
                end
            end
        end
        
        %% Calculate "d"
        for i = 1 : n
            for j = 1 : n
                cor = zeros(n);
                for k = intersect(s{i}, s{j})
                    sv = failure_seq(k).sv.comp;
                    try
                        xcor = xcorr(sv([i, j], :)', 1, 'coeff');
                        if ~isnan(xcor(1, 2))
                            cor(i, j) = cor(i, j) + abs(xcor(1, 2));
                        end
                    catch
                    end
                end
                if ~isempty(s{i})
                    d = d + cor / length(s{i});
                end
            end
        end
    case 'rdc'
        %% Generate s
        % Mapping from components to failure cases in which they are failed
        for i = 1 : n
            s{i} = [];
            for j = 1 : length(failure_seq)
                if any([failure_seq(j).comp{:}] == i)
                    if ~any(s{i} == j)
                        s{i} = [s{i}, j];
                    end
                end
            end
        end
        
        %% Calculate "d"
        for i = 1 : n
            for j = 1 : n
                cor = zeros(n);
                for k = intersect(s{i}, s{j})
                    sv = failure_seq(k).sv.comp;
                    try
                        cor(i, j) = cor(i, j) + rdc(sv(i, :)', ...
                            [sv(j, 2 : end), sv(j, end)]', ...
                            1, 0.1);
                    catch
                    end
                end
                if ~isempty(s{i})
                    d = d + cor / length(s{i});
                end
            end
        end
end

warning on all
rmpath('lib')
end