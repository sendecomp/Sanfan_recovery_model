function head(file_name, d, num)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function finds and prints head (largest values) of dependency
% matrices.
% INPUTS:
%  -file_name: Name of the input system
%  -d: Dependency matrix
%  -num: Number of elements to be printed
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     January 19, 2017
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Headers
DATA_PATH = 'data';
LIB_PATH = 'lib';
addpath(LIB_PATH);

%% Read number of components in each category
load(fullfile(DATA_PATH, [file_name, '_comps.mat']))

%% Head of d
[sd, idx] = sort(d(:), 'descend');
[sorted_row_idx, sorted_col_idx] = ind2sub(size(d), idx);

%% Display head with name of components
fields = fieldnames(comps);
comp_type = [];
n = 0;
for i = 1 : numel(fields)
    comps.(fields{i}).start_idx = n; % Index for accessing the first
    % element of each category of components
    n = n + comps.(fields{i}).n;
    comp_type = [comp_type; repmat(fields(i), comps.(fields{i}).n, 1)];
end
idx_converter = zeros(size(d, 1), 1);
for i = 1 : size(d, 1)
    for j = 1 : numel(fields)
        if i > comps.(fields{j}).start_idx && ...
                i <= comps.(fields{j}).start_idx + comps.(fields{j}).n
            idx_converter(i) = i - comps.(fields{j}).start_idx;
            break
        end
    end
end
i = 1;
j = 1;
while i <= numel(d) && j <= num
    if sorted_row_idx(i) == sorted_col_idx(i)
        i = i + 1;
        continue
    end
    
    % Use for restricting the output to specific subsystem dependencies:
    phyphy = @() sorted_row_idx(i) <= comps.line.n && ...
        sorted_col_idx(i) <= comps.line.n;
    phycy = @() sorted_row_idx(i) <= comps.line.n && ...
        sorted_col_idx(i) > comps.line.n;
    cyphy = @() sorted_row_idx(i) > comps.line.n && ...
        sorted_col_idx(i) <= comps.line.n;
    cycy = @() sorted_row_idx(i) > comps.line.n && ...
        sorted_col_idx(i) > comps.line.n;
    % Replace 'true' with any combination of the above anonymous functions
    if phyphy()
        from = comp_name(file_name, comp_type{sorted_row_idx(i)}, ...
            idx_converter(sorted_row_idx(i)));
        to = comp_name(file_name, comp_type{sorted_col_idx(i)}, ...
            idx_converter(sorted_col_idx(i)));
        fprintf('%2.0f. %11s, %11s : %.3f\n', ...
            j, from(4:end), to(4:end), sd(i));
        j = j + 1;
    end
    i = i + 1;
end

%% Clean
rmpath('lib')