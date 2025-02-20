function importance = comp_imp(file_name, n)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function analyzes a given failure sequence and outputs metrics
% needed for importance analysis, including fragility and criticality.
% INPUT:
%  -file_name: Name of the failure sequence file for which component
%   importance analysis will be done. Failure sequence is an array of
%   structures with at least the follwing fields:
%       'line', 'csi', and 'anve'
%   Each element of 'line' represents a cell of vectors of lines that are
%   overloaded and tripped during that failure case. anve and csi represent
%   sevice indices for system at that instance.
%  -n: Number of lines
% OUTPUT:
%  -importance: An array of structures with a length equal to the number of
%   components and with these fields:
%       -'fragility': Fragility of components
%       -'criticality': Criticality of components
%       -'table': Fragility and criticality sorted and formatted into a
%       table
%       -'s': A mapping from components to failure cases in which they are
%       failed. For example, importance.s{1} is a vector of failure cases
%       in which component 1 has failed.
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     April 23, 2015
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FAILURE_SEQ_PATH = 'failure_seq';
load(fullfile(FAILURE_SEQ_PATH, [file_name '.mat']));
m = length(failure_seq);

%% Generate s
s = {}; % Mapping from components to failure cases in which they are failed
for i = 1 : n
    s{i} = [];
    for j = 1 : m
        % Adding placeholders for correct indexing
        for k = 1 : length(failure_seq(j).line)
            if isempty(failure_seq(j).line{k})
                failure_seq(j).line{k} = 0;
            end
        end
        % Construct s
        if any([failure_seq(j).line{:}] == i)
            if ~any(s{i} == j)
                s{i} = [s{i}, j];
            end
        end
    end
end

%% Extract extent and rate - for CSI only
global_rate_max = 0;
global_extent_max = 0;
for j = 1 : m
    failure_seq(j).extent_csi = max(failure_seq(j).csi) - ...
        min((failure_seq(j).csi));
    global_extent_max = max(global_extent_max, failure_seq(j).extent_csi);

    failure_seq(j).d1_csi = [0 -diff(failure_seq(j).csi)];
    failure_seq(j).rate_csi = max(failure_seq(j).d1_csi);
	global_rate_max = max(global_rate_max, failure_seq(j).rate_csi);

    failure_seq(j).d2_csi = [0 diff(failure_seq(j).d1_csi)];
    failure_seq(j).impact_max_csi = max(failure_seq(j).d2_csi);
end

%% Calculate fragility for each component
frag = zeros(n, 1);
for i = 1 : n
    frag(i) = length(s{i}) / m;
end

%% Calculate criticality for each component - based on CSI only
crit = zeros(n, 1);
for i = 1 : n
    sum_norm_crit = 0;
    for j = s{i}
		norm_extent = failure_seq(j).extent_csi / global_extent_max;
        if failure_seq(j).rate_csi == 0
            norm_impact1 = 0;
        else
            norm_impact1 = failure_seq(j).d1_csi( ...
                [failure_seq(j).line{:}] == i) / ...
                failure_seq(j).rate_csi;
        end
        if failure_seq(j).impact_max_csi == 0 || ...
                failure_seq(j).d2_csi([failure_seq(j).line{:}] == i) <= 0
            norm_impact2 = 0;
        else
            norm_impact2 = failure_seq(j).d2_csi( ...
                [failure_seq(j).line{:}] == i) / ...
                failure_seq(j).impact_max_csi;
        end
        sum_norm_crit = sum_norm_crit + ...
            norm_extent * 1 * norm_impact2;
    end
    crit(i) = sum_norm_crit / m;
end

%% Export values
importance = struct();
importance.fragility = frag;
importance.criticality = crit;
[frag_sorted, frag_sorted_idx] = sort(frag, 'descend');
[crit_sorted, crit_sorted_idx] = sort(crit, 'descend');
header = sprintf('\tFragility\t\t||\tCriticality\n');
header = [header, repmat('-', 1, 40), sprintf('\n')];
importance.table = [header, ...
    sprintf('%.0f\t|\t%.6f\t||\t%.0f\t|\t%.6f\n', ...
    [frag_sorted_idx'; frag_sorted'; crit_sorted_idx'; crit_sorted'])];
importance.s = s;

end
