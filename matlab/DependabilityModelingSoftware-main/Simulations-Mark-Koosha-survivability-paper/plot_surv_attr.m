function plot_surv_attr(file_name, pdf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots survivability attributes (extent and rate of degradation) in
% various formats.
% INPUT:
%  -file_name: Name of the failure sequence file for which plots are
%  generated.
%  -save2pdf: Export figures into PDF files if true.
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     April 23, 2015
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FAILURE_SEQ_PATH = 'failure_seq';
LIB_PATH = 'lib';
addpath(LIB_PATH);
T_E = 3;

load(fullfile(FAILURE_SEQ_PATH, [file_name '.mat']));

line_width = 1.2;
alpha = 0.20; % 0~1 - larger values for fewer number of failure cases
hist_intensity = 10; % 1~10 - larger values for enhancement of small areas
m = length(failure_seq);
n_points = length(failure_seq(1).csi);
t = 0 : n_points - 1;
cmap = buildcmap('wrr'); % Build colormap
font = 'Times New Roman';
font_size = 13;
hist_n_bins = 6;

fig_hndl = figure('Name','CSI vs. Time','NumberTitle','off');
for i = 1 : m
    failure_seq(i).extent_csi = max(failure_seq(i).csi) - ...
        min((failure_seq(i).csi));
    failure_seq(i).rate_csi = max(-diff(failure_seq(i).csi));
    patchline(t, failure_seq(i).csi, 'EdgeColor', 'r', ...
        'LineWidth', line_width, 'EdgeAlpha', alpha);
    hold on
end

xlim([0 n_points - 1]), ylim([-0.05 1.05])
format_ticks(gca, {'\it t_e'}, [], T_E - 1);
set(gca, 'FontName', font, 'Fontsize', font_size)
xlabel('Time'), ylabel('CSI')
colormap(cmap);
cb = colorbar;
ylabel(cb, ['Number of Failure Cases Out of ' num2str(m)], ...
    'FontName', font, 'Fontsize', font_size)
set(cb, 'FontName', font, 'Fontsize', font_size);
caxis([0 m]);

yl = get(gca, 'ylim');
hold on
plot([T_E - 1, T_E - 1], yl, 'LineStyle', '--', 'Color', 'k')

% hx = graph2d.constantline(T_E - 1, 'LineStyle', '--', 'Color', 'k');
% changedependvar(hx, 'x');
hold off
if pdf
    save2pdf([file_name '_csi'], fig_hndl, 600);
end

fig_hndl = figure('Name','ANVE vs. Time','NumberTitle','off');
for i = 1 : m
    failure_seq(i).extent_anve = max(failure_seq(i).anve) - ...
        min((failure_seq(i).anve));
    failure_seq(i).rate_anve = max(-diff(failure_seq(i).anve));
    patchline(t, failure_seq(i).anve, 'EdgeColor', 'r', ...
        'LineWidth', line_width, 'EdgeAlpha', alpha);
    hold on
end

xlim([0 n_points - 1]), ylim([-0.05 1.05])
format_ticks(gca, {'\it t_e'}, [], T_E - 1);
set(gca, 'FontName', font,'Fontsize', font_size)
xlabel('Time'), ylabel('ANVE (per unit)')
colormap(cmap);
cb = colorbar;
ylabel(cb, ['Number of Failure Cases Out of ' num2str(m)], ...
    'FontName', font, 'Fontsize', font_size)
set(cb, 'FontName', font, 'Fontsize', font_size);
caxis([0 m]);

plot([T_E - 1, T_E - 1], yl, 'LineStyle', '--', 'Color', 'k')

% hx = graph2d.constantline(T_E - 1, 'LineStyle', '--', 'Color', 'k');
% changedependvar(hx, 'x');
hold off
if pdf
    save2pdf([file_name '_anve'], fig_hndl, 600);
end

%  fig_hndl = figure('Name','CSI Extent of Degradation Histogram', ...
%      'NumberTitle','off');
% hist([failure_seq(:).extent_csi]);
% hist_bars = findobj(gca, 'Type', 'patch');
% set(hist_bars, 'FaceColor', [0 0.5 0.5], 'EdgeColor', 'k');
% set(gca, 'FontName', font, 'Fontsize', font_size)
% xlabel('\it\delta')
% ylabel(['Number of Failure Cases Out of ' num2str(n_sim)])
% if pdf
%     save2save2pdf([file_name '_extent_hist_csi'],fig_hndl,600);
% end
% 
% fig_hndl = figure('Name','CSI Rate of Degradation Histogram', ...
%      'NumberTitle','off');
% hist([failure_seq(:).rate_csi]);
% hist_bars = findobj(gca, 'Type', 'patch');
% set(hist_bars, 'FaceColor', [0 0.5 0.5], 'EdgeColor', 'k');
% set(gca, 'FontName', font, 'Fontsize', font_size)
% xlabel('\it\rho')
% ylabel(['Number of Failure Cases Out of ' num2str(n_sim)])
% if pdf
%     save2save2pdf([file_name '_rate_hist_csi'], fig_hndl, 600);
% end
% 
% fig_hndl = figure('Name','ANVE Extent of Degradation Histogram', ...
%      'NumberTitle','off');
% hist([failure_seq(:).extent_anve]);
% hist_bars = findobj(gca, 'Type', 'patch');
% set(hist_bars, 'FaceColor', [0 0.5 0.5], 'EdgeColor', 'k');
% set(gca, 'FontName', font, 'Fontsize', font_size)
% xlabel('\it\delta')
% ylabel(['Number of Failure Cases Out of ' num2str(n_sim)])
% if pdf
%     save2save2pdf([file_name '_extent_hist_anve'], fig_hndl, 600);
% end
% 
% fig_hndl = figure('Name','ANVE Rate of Degradation Histogram', ...
%      'NumberTitle','off');
% hist([failure_seq(:).rate_anve]);
% hist_bars = findobj(gca, 'Type', 'patch');
% set(hist_bars, 'FaceColor', [0 0.5 0.5], 'EdgeColor', 'k');
% set(gca, 'FontName', font, 'Fontsize', font_size)
% xlabel('\it\rho')
% ylabel(['Number of Failure Cases Out of ' num2str(n_sim)])
% if pdf
%     save2save2pdf([file_name '_rate_hist_anve'], fig_hndl, 600);
% end

xmax = 0.3; % max([failure_seq(:).rate_csi]);
ymax = 1; % max([failure_seq(:).extent_csi]);
x_range = linspace(0, ceil(xmax * 10) / 10, hist_n_bins);
y_range = linspace(0, ceil(ymax * 10) / 10, hist_n_bins);
fig_hndl = figure('Name','CSI Extent-Rate of Degradation Histogram', ...
    'NumberTitle','off');
csi_hist = hist3([[failure_seq(:).extent_csi]', ...
    [failure_seq(:).rate_csi]'], 'Edges', {y_range, x_range});
contourf(x_range, y_range, ...
    mat2gray(csi_hist .^ (1 / hist_intensity)));
colormap(jet);
cb = colorbar;
ylabel(cb, ['Number of Failure Cases Out of ' num2str(m)], ...
    'FontName', font, 'Fontsize', font_size)
set(cb, 'FontName', font, 'Fontsize', font_size);
set(cb, 'YTickLabel', sprintf('%.0f|', ...
    max(csi_hist(:)) / 10 : ...
    max(csi_hist(:)) / 10 : ...
    max(csi_hist(:))))
set(gca, 'FontName', font, 'Fontsize', font_size)
xlabel('\it\rho'), ylabel('\it\delta')
if pdf
    save2pdf([file_name '_hist_csi'], fig_hndl, 600);
end


xmax = 0.3; % max([failure_seq(:).rate_anve]);
ymax = 1; % max([failure_seq(:).extent_anve]);
x_range = linspace(0, ceil(xmax * 10) / 10, hist_n_bins);
y_range = linspace(0, ceil(ymax * 10) / 10, hist_n_bins);
fig_hndl = figure('Name','ANVE Extent-Rate of Degradation Histogram', ...
    'NumberTitle','off');
anve_hist = hist3([[failure_seq(:).extent_anve]', ...
    [failure_seq(:).rate_anve]'], 'Edges', {y_range, x_range});
contourf(x_range, y_range, ...
    mat2gray(anve_hist .^ (1 / hist_intensity)));
colormap(jet);
cb = colorbar;
ylabel(cb, ['Number of Failure Cases Out of ' num2str(m)], ...
    'FontName', font, 'Fontsize', font_size)
set(cb,'FontName', font, 'Fontsize', font_size);
set(cb, 'YTickLabel', sprintf('%.0f|', ...
    max(anve_hist(:)) / 10 : ...
    max(anve_hist(:)) / 10 : ...
    max(anve_hist(:))))
set(gca, 'FontName', font, 'Fontsize', font_size)
xlabel('\it\rho'), ylabel('\it\delta')
if pdf
    save2pdf([file_name '_hist_anve'], fig_hndl, 600);
end

rmpath('lib')

end