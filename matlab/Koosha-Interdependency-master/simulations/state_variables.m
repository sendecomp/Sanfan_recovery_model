function state_variables(file_name, case_number, pdf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots state variables of components for a specific failure
% sequence. It also prints correlation between the state variables.
% INPUTS:
%  -file_name: Name of the input system
%  -case_number: Index of selected failure sequence
%  -pdf: A boolean value that specifies if PDF file should be generated
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     January 19, 2017
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define Constants
FAILURE_SEQ_PATH = 'failure_seq';
LIB_PATH = 'lib';
addpath(LIB_PATH);
MARKER_SIZE = 16;
FONT = 'Times New Roman';
FONT_SIZE = 12;
COLORS = colors();
MAX_LINE_FLOW = 1.75;

%% Categorize components
load(fullfile(FAILURE_SEQ_PATH, [file_name '.mat']));
failure_sequence = failure_seq(case_number);
sel = struct();
nf = 0;
comp = {'line', 'facts', 'pmu', 'ds'};
steps = length(failure_sequence.(comp{1}));
for i = 1 : steps
    for j = 1 : length(comp)
        fi = failure_sequence.(comp{j}){i};
        for k = fi
            nf = nf + 1;
            sel(nf).comp_type = comp{j};
            sel(nf).comp_idx = k;
        end
    end
end

%% Get state variables
sv = repmat({[]}, nf, 1);
failure_idx = repmat({[]}, nf, 1);
time_span = 0;
for i = 1 : nf
    all_sv = [failure_sequence.sv.(sel(i).comp_type){:}];
    sv{i} = abs(all_sv(sel(i).comp_idx, :));
    sv{i}(sv{i} > MAX_LINE_FLOW) = MAX_LINE_FLOW;
    sv{i}(isnan(sv{i})) = 0;
    state = find(sv{i} == 0);
    failure_idx{i} = state(1);
    time_span = max(time_span, state(1));
end
sv = cell2mat(sv);
time_span = time_span + 2;

%% Print normalized correlation between state variables
ncc = xcorr(sv', 1, 'coeff');
ncc = ncc(1, :);
[~, cor_idx] = sort(ncc, 'descend');
disp('Normalized Cross-Correlation')
for i = cor_idx
    from = floor((i-1) / nf) + 1;
    to = mod(i-1, nf) + 1;
    if from ~= to
        fprintf('%8s -> %8s: %.4f', ...
            comp_name(file_name, sel(from).comp_type, sel(from).comp_idx, false), ...
            comp_name(file_name, sel(to).comp_type, sel(to).comp_idx, false), ...
            ncc(i))
        if from > to
            fprintf(' *\n')
        else
            fprintf('\n')
        end
    end
end

%% Print Pearson correlation between state variables
pcc = zeros(nf);
for i = 1 : nf
    for j = 1 : nf
        try
            pcc_ = corrcoef(sv(i, :)', [sv(j, 2 : end), sv(j, end)]');
            pcc_(isnan(pcc_)) = 0;
            pcc(i, j) = pcc_(1, 2);
        catch
            pcc(i, j) = 0;
        end
    end
end
pcc = reshape(pcc', 1, nf ^ 2);
[~, pcc_idx] = sort(pcc, 'descend');
disp('Pearson Correlation Coefficient')
for i = pcc_idx
    from = floor((i-1) / nf) + 1;
    to = mod(i-1, nf) + 1;
    if from ~= to
        fprintf('%8s -> %8s: %.4f', ...
            comp_name(file_name, sel(from).comp_type, sel(from).comp_idx, false), ...
            comp_name(file_name, sel(to).comp_type, sel(to).comp_idx, false), ...
            pcc(i))
        if from > to
            fprintf(' *\n')
        else
            fprintf('\n')
        end
    end
end

%% Print RDC between state variables
rdc_ = zeros(nf);
warning off all
for i = 1 : nf
    for j = 1 : nf
        try
            rdc_(i, j) = rdc(sv(i, :)', [sv(j, 2 : end), sv(j, end)]', ...
                1, 0.1);
        catch
            rdc_(i, j) = 0;
        end
    end
end
warning on all
rdc_ = reshape(rdc_', 1, nf ^ 2);
[~, rdc_idx] = sort(rdc_, 'descend');
disp('Randomized Dependence Coefficient')
for i = rdc_idx
    from = floor((i-1) / nf) + 1;
    to = mod(i-1, nf) + 1;
    if from ~= to
        fprintf('%8s -> %8s: %.4f', ...
            comp_name(file_name, sel(from).comp_type, sel(from).comp_idx, false), ...
            comp_name(file_name, sel(to).comp_type, sel(to).comp_idx, false), ...
            rdc_(i))
        if from > to
            fprintf(' *\n')
        else
            fprintf('\n')
        end
    end
end

%% Plot state variables
h = figure('Position', [400, 100, 550, 1 + nf*50]);
for i = 1 : nf
    ah = subtightplot(nf, 1, i, [0.01, 0.15], [0.10 0.02], [0.12 0.07]);
    annotation_pinned('textarrow', ...
        repmat((failure_idx{i}-1)/(time_span-1), 1, 2), ...
        [0.8 0.2], 'Color', 'black', 'lineWidth', 1, 'axes', ah);
    plot(sv(i, :), '.-', 'Color', COLORS(i, :), 'Markers', MARKER_SIZE)
    if i < nf
        set(ah,'xticklabel', {[]})
    else
        set(ah,'xticklabel', 0 : steps)
        xlabel('Simulation Time', 'FontSize', FONT_SIZE, ...
            'FontName', FONT)
    end
    set(ah, 'yticklabel', {[]})
    xlim([1 time_span])
    switch sel(i).comp_type
        case 'line'
            ylim([-0.1 2.0])
        otherwise
            ylim([-0.1 1.1])
    end
    ylabel(comp_name(file_name, sel(i).comp_type, sel(i).comp_idx))
    set(get(ah, 'ylabel'), 'rotation', 0, ...
        'FontSize', FONT_SIZE, 'FontName', FONT, ...
        'horizontalAlignment', 'right', ...
        'verticalAlignment', 'middle')
    set(ah, 'xgrid', 'on')
    set(ah, 'FontName', FONT)
end
ax = axes('Position', [0.97 0.50 1 1], 'Visible', 'off');
set(gcf, 'CurrentAxes', ax)
text(0, 0, 'State Variables', ...
'VerticalAlignment', 'middle', ...
'HorizontalAlignment', 'center', ...
'Rotation', 270, ...
'FontSize', FONT_SIZE, ...
'FontName', FONT)

%% Save PDF and clean
if pdf, save2pdf(['sv_' file_name '_' num2str(case_number)], h, 600); end
rmpath('lib')