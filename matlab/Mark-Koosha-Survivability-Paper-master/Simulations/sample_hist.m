LIB_PATH = 'lib';
addpath(LIB_PATH);

font = 'Times New Roman';
font_size = 13;
hist_n_bins = 20;
xmax = 1;
ymax = 1;
x_range = linspace(0, ceil(xmax * 10) / 10, hist_n_bins);
y_range = linspace(0, ceil(ymax * 10) / 10, hist_n_bins);
fig_hndl = figure('Name','Sample Extent-Rate of Degradation Histogram', ...
    'NumberTitle','off');
hist = hist3([0.6, 0.3], 'Edges', {y_range, x_range});
contourf(x_range, y_range, mat2gray(hist));
colormap(jet);
cb = colorbar;
ylabel(cb, 'Number of Failure Cases', ...
    'FontName', font, 'Fontsize', font_size)
set(cb,'FontName', font, 'Fontsize', font_size);
set(gca, 'FontName', font, 'Fontsize', font_size)
xlabel('\it\rho'), ylabel('\it\delta')
save2pdf('sample_hist', fig_hndl, 600);

rmpath('lib')