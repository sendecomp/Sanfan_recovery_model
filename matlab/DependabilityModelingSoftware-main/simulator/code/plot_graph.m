function plot_graph(file_name, d, legends, pdf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots digraph of a given dependency matrix.
% INPUTS:
%  -file_name: Name of the input system
%  -d: Dependency matrix
%  -pdf: A boolean value that specifies if PDF file should be generated
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     January 19, 2017
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define Constants
DATA_PATH = 'data';
LIB_PATH = 'lib';
addpath(LIB_PATH);
QUANTILE = 0.80; % 80-85% for IEEE-14 and 97-98% for IEEE-57
NM_NODES = struct('Marker', 'o', 'MarkerSize', 4, 'Color', 'b');
TAU_NUM = 5;
TAU_NODES = struct('Marker', '^', ...
    'MarkerSize', 8, ...
    'Color', [0.2 1.0 0.2], ...
    'MarkerFaceColor', [0.2 1.0 0.2], ...
    'LineStyle', 'none', ...
    'DisplayName', 'Large Out-Degree');
NU_NUM = 5;
NU_NODES = struct('Marker', 'v', ...
    'MarkerSize', 8, ...
    'Color', [1.0 0.8 0], ...
    'MarkerFaceColor', [1.0 0.8 0], ...
    'LineStyle', 'none', ...
    'DisplayName', 'Large In-Degree');
TAU_NU_NODES = struct('Marker', 'd', ...
    'MarkerSize', 9, ...
    'Color', [1.0 0.2 1.0], ...
    'MarkerFaceColor', [1.0 0.2 1.0], ...
    'LineStyle', 'none', ...
    'DisplayName', 'Large In- and Out-Degree');
NODES_LGND_BOX = [0.6, 0.85, 0.4, 0.15];
EDGES_NUM = 5;
NM_EDGES = struct('EdgeColor', [0 0.447 0.741], ...
    'LineWidth', 5, ...
    'EdgeAlpha', 0.6, ...
    'ArrowSize', 12);
LG_EDGES = struct('EdgeColor', 'r', ...
    'LineWidth', 5, ...
    'EdgeAlpha', 0.6, ...
    'ArrowSize', 12, ...
    'DisplayName', 'Large Direct Dependency');
EDGES_LGND_BOX = [0, 0.85, 0.4, 0.15];
ZOOM = 1.3;

%% Read number of components in each category
load(fullfile(DATA_PATH, append(file_name, '_comps.mat')))

%% Clean and trim d
d(logical(eye(size(d)))) = 0;
epsilon = max(quantile(d(:), QUANTILE), 0.01);
d(d < epsilon) = 0;

%% Make a list of component names
fields = fieldnames(comps);
comp_type = [];
n = 0;
for i = 1 : numel(fields)
    comps.(fields{i}).start_idx = n;
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
    node_names{i} = [' ', comp_name(file_name, comp_type{i}, ...
        idx(i), false), ' '];
end
[~, idx_last, idx] = unique(node_names(:));
duplicates = setdiff(idx, idx_last);
for i = 1 : numel(duplicates)
    node_names{duplicates(i)} = [node_names{duplicates(i)} '*'];
end

%% Plot graph
g = digraph(d, node_names, 'OmitSelfLoops');
weights = g.Edges.Weight / max(g.Edges.Weight);
if legends
    fig_h = figure('Position', [400, 100, 500, 530]);
else
    fig_h = figure('Position', [400, 100, 500, 500]);
end
subtightplot(1, 1, 1, [0.01, 0.01], 0.03, 0.03)
ph = plot(g, ...
    'Layout', 'circle', ...
    'Marker', NM_NODES.Marker, ...
    'MarkerSize', NM_NODES.MarkerSize, ...
    'NodeColor', NM_NODES.Color, ...
    'EdgeColor', NM_EDGES.EdgeColor, ...
    'LineWidth', NM_EDGES.LineWidth * weights, ...
    'EdgeAlpha', NM_EDGES.EdgeAlpha, ...
    'ArrowSize', NM_EDGES.ArrowSize);
zoom(ZOOM)
ylim_ = ylim;
if legends
    ylim([ylim_(1), ylim_(2) + 0.35])
end

%% Highlight edges with large weights
[~, d_si] = sort(d(:), 'descend');
[top_row, top_col] = ind2sub(size(d), d_si);
for i = 1 : EDGES_NUM
    highlight(ph, top_row(i), top_col(i), ...
        'EdgeColor', LG_EDGES.EdgeColor);
end

%% Highlight nodes with largest tau and nu values
dep = dep_idx(d);
[~, tau_si] = sort(dep.tau, 'descend');
[~, nu_si] = sort(dep.nu, 'descend');
highlight(ph, tau_si(1 : TAU_NUM), ...
    'Marker', TAU_NODES.Marker, ...
    'MarkerSize', TAU_NODES.MarkerSize, ...
    'NodeColor', TAU_NODES.Color);
highlight(ph, nu_si(1 : NU_NUM), ...
    'Marker', NU_NODES.Marker, ...
    'MarkerSize', NU_NODES.MarkerSize, ...
    'NodeColor', NU_NODES.Color);
highlight(ph, intersect(tau_si(1 : TAU_NUM), nu_si(1 : NU_NUM)), ...
    'Marker', TAU_NU_NODES.Marker, ...
    'MarkerSize', TAU_NU_NODES.MarkerSize, ...
    'NodeColor', TAU_NU_NODES.Color);

if legends
    %% Legend for nodes
    hold on
    nodes(1) = plot(NaN, NaN);
    set(nodes(1), TAU_NODES);
    nodes(2) = plot(NaN, NaN);
    set(nodes(2), NU_NODES);
    if ~isempty(intersect(tau_si(1 : TAU_NUM), nu_si(1 : NU_NUM)))
        nodes(3) = plot(NaN, NaN);
        set(nodes(3), TAU_NU_NODES);
        lgd_n = legend(nodes, ...
            TAU_NODES.DisplayName, ...
            NU_NODES.DisplayName, ...
            TAU_NU_NODES.DisplayName);
    else
        lgd_n = legend(nodes, ...
            TAU_NODES.DisplayName, ...
            NU_NODES.DisplayName);
    end
    legend('boxoff'),
    set(lgd_n, 'Position', NODES_LGND_BOX)
    title(lgd_n, 'Notable Nodes')
    axis off

    %% Legend for Edges
    ah = axes('Position', get(gca, 'Position'), 'visible', 'off');
    hold on
    plot(ah, NaN, NaN, ...
        'Color', LG_EDGES.EdgeColor, ...
        'LineWidth', 0.8 * LG_EDGES.LineWidth);
    lgd_e = legend(ah, ...
        LG_EDGES.DisplayName);
    legend('boxoff')
    set(lgd_e, 'Position', EDGES_LGND_BOX)
    title(lgd_e, 'Notable Edges')
end
axis off

if pdf, save2pdf(append('graph_', file_name), fig_h, 600); end

rmpath('lib')

% figure;
% p2 = plot(g, 'LineWidth', LINE_WIDTH * weights, ...
%     'Layout', 'layered', ...
%     'Direction', 'up', ...
%     'Sources', 1 : 20, 'Sinks', 21 : 27, ...
%     'EdgeAlpha', EDGE_ALPHA);
% axis off
% zoom(1.3)
% 
% warning off all
% % Phy-Phy
% for i = 1 : comps.line.n
%     s = successors(g, i);
%     highlight(p2, i, s(s <= comps.line.n), 'EdgeColor', [1 0 0], 'LineStyle', '-')
% end
% % Phy-Cy
% for i = 1 : comps.line.n
%     s = successors(g, i);
%     highlight(p2, i, s(s > comps.line.n), 'EdgeColor', [0.51 0.38 0.58], 'LineStyle', '-')
% end
% % Cy-Cy
% for i = comps.line.n + 1 : n
%     s = successors(g, i);
%     highlight(p2, i, s(s > comps.line.n), 'EdgeColor', [0 0.44 0.73], 'LineStyle', '-')
% end
% % Cy-Phy
% for i = comps.line.n + 1 : n
%     s = successors(g, i);
%     highlight(p2, i, s(s <= comps.line.n), 'EdgeColor', [0 0.70 0.33], 'LineStyle', '-')
% end
% warning on all