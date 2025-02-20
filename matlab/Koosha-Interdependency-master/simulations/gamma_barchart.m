function gamma_barchart(file_name, pdf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots bar chart for gamma values.
% INPUTS:
%  -file_name: Name of the input system
%  -pdf: A boolean value that specifies if PDF file should be generated
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     February 13, 2017
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Headers
DATA_PATH = 'data';
D_PATH = 'd';
LIB_PATH = 'lib';
addpath(LIB_PATH);
FONT = 'Times New Roman';
FONT_SIZE = 12;
FONT_SIZE_ANNOTATE = 10;
SUBSYSTEMS = {'Physical-Physical', 'Physical-Cyber', 'Cyber-Physical', ...
    'Cyber-Cyber'};

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

%% Calculate dependency indices
dep_cor = dep_idx(d_cor, comps.line.n);
dep_rdc = dep_idx(d_rdc, comps.line.n);
dep_qis = dep_idx(d_qis, comps.line.n);

%% Plot gamma values
gamma = [ ...
    dep_cor.gamma.phyphy, dep_rdc.gamma.phyphy, dep_qis.gamma.phyphy; ...
    dep_cor.gamma.phycy, dep_rdc.gamma.phycy, dep_qis.gamma.phycy; ...
    dep_cor.gamma.cyphy, dep_rdc.gamma.cyphy, dep_qis.gamma.cyphy; ...
    dep_cor.gamma.cycy, dep_rdc.gamma.cycy, dep_qis.gamma.cycy];
gamma = gamma(:, 2:end);
fh = figure;
ah = subtightplot(1, 1, 1, [0.01, 0.01], [0.07 0.02], [0.09 0.02]);
bar(gamma');
colormap([ ...
    1.00, 0.10, 0.10; ...
    0.51, 0.38, 0.58; ...
    0.00, 0.70, 0.33; ...
    0.00, 0.44, 0.73]);
% xticklabels({'PCC', 'RDC', 'Causation'})
xticklabels({'Correlation (RDC)', 'Causation'})
set(ah, 'FontName', FONT, 'FontSize', FONT_SIZE)

%% Annotation on the bars
XPOS = [-0.275, -0.090, 0.090, 0.275];
YPOS = 0;
for i = 1 : numel(SUBSYSTEMS)
    for j = 1 : size(gamma, 2)
        x = j + XPOS(i);
        y = gamma(i, j) + YPOS;
        if gamma(i, j) < 0.3 * max(gamma(:))
            text(x , y, [' ', SUBSYSTEMS{i}], ...
                'Rotation', 90, 'FontSize', FONT_SIZE_ANNOTATE, ...
                'Color', 'k', 'HorizontalAlignment', 'left')
        else
            text(x , y, [SUBSYSTEMS{i}, ' '], ...
                'Rotation', 90, 'FontSize', FONT_SIZE_ANNOTATE, ...
                'Color', 'w', 'HorizontalAlignment', 'right')
        end
    end
end

%% Save PDF and clean
if pdf, save2pdf([file_name '_gamma'], fh, 600); end
rmpath('lib')