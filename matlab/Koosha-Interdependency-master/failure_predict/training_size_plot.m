pdf = true;
FONT = 'Times New Roman';
FONT_SIZE = 11;

ieee14_tr_sz = [250 500 1000:1000:10000];
ieee14_pre_smpl = [90.96 95.58 97.02 97.44 97.53 98.23 99.19 98.05 ...
    99.19 99.03 99.25 98.89];
ieee14_rec_smpl = [85.74 90.77 94.85 95.30 96.16 96.75 97.84 96.63 ...
    98.52 97.78 98.50 97.74];
ieee14_fsc_smpl = [87.12 92.20 95.30 95.82 96.37 97.18 98.25 97.00 ...
    98.61 98.15 98.67 98.03];
ieee14_pre_cmplx = [84.89 82.85 88.85 90.06 89.36 90.31 90.09 88.48 ...
    90.14 90.95 88.55 88.88];
ieee14_rec_cmplx = [71.55 72.99 82.21 83.60 81.44 83.49 83.61 84.07 ...
    84.66 85.10 83.53 83.62];
ieee14_fsc_cmplx = [75.72 76.09 83.79 85.28 83.53 85.22 85.15 84.88 ...
    86.03 86.73 84.65 84.76];

ieee57_tr_sz = [250 500 1000 2000:2000:20000];
ieee57_pre_smpl = [75.99 86.08 94.23 97.23 98.14 98.14 98.23 98.77 98.81 98.70 98.83 99.16 98.88];
ieee57_rec_smpl = [70.29 82.51 90.17 94.83 96.89 96.94 97.67 98.30 98.30 97.58 98.13 98.60 97.92];
ieee57_fsc_smpl = [72.01 83.14 91.36 95.52 97.27 97.30 97.82 98.37 98.44 97.89 98.31 98.78 98.12];
ieee57_pre_cmplx = [63.99 78.14 82.19 86.49 87.16 85.72 88.22 86.31 83.02 89.00 87.43 85.34 84.18];
ieee57_rec_cmplx = [53.56 66.51 67.63 73.85 75.63 73.14 76.12 74.38 71.84 75.73 73.44 73.45 72.22];
ieee57_fsc_cmplx = [55.93 69.22 71.49 77.27 78.62 76.31 79.39 77.48 74.72 79.17 77.08 76.58 75.30];

h = figure;
subtightplot(1, 1, 1, [0.01, 0.01], [0.16 0.02], [0.09 0.02])
plot(ieee14_tr_sz, ieee14_pre_smpl, '-v', ...
    'DisplayName', 'Precision (Simple Dataset)')
hold on
plot(ieee14_tr_sz, ieee14_rec_smpl, '-o', ...
    'DisplayName', 'Recall (Simple Dataset)')
plot(ieee14_tr_sz, ieee14_fsc_smpl, '-*', ...
    'DisplayName', '{\itF_1} Score (Simple Dataset)')
plot(ieee14_tr_sz, ieee14_pre_cmplx, '-^', ...
    'DisplayName', 'Precision (Complex Dataset)')
plot(ieee14_tr_sz, ieee14_rec_cmplx, '-s', ...
    'DisplayName', 'Recall (Complex Dataset)')
plot(ieee14_tr_sz, ieee14_fsc_cmplx, '-x', ...
    'DisplayName', '{\itF_1} Score (Complex Dataset)')
legend('show', 'Location', 'southeast')
ax = gca;
ax.XTickLabel = num2str(ax.XTick');
xtickangle(45)
set(gca, 'FontName', FONT, 'Fontsize', FONT_SIZE)
xlabel('Size of Training Dataset', 'FontSize', FONT_SIZE, 'FontName', FONT)
ylabel('Performace Measures (%)', 'FontSize', FONT_SIZE, 'FontName', FONT)
if pdf, save2pdf('ieee14_tr_sz' , h, 600); end

h = figure;
subtightplot(1, 1, 1, [0.01, 0.01], [0.16 0.02], [0.09 0.02])
plot(ieee57_tr_sz, ieee57_pre_smpl, '-v', ...
    'DisplayName', 'Precision (Simple Dataset)')
hold on
plot(ieee57_tr_sz, ieee57_rec_smpl, '-o', ...
    'DisplayName', 'Recall (Simple Dataset)')
plot(ieee57_tr_sz, ieee57_fsc_smpl, '-*', ...
    'DisplayName', '{\itF_1} Score (Simple Dataset)')
plot(ieee57_tr_sz, ieee57_pre_cmplx, '-^', ...
    'DisplayName', 'Precision (Complex Dataset)')
plot(ieee57_tr_sz, ieee57_rec_cmplx, '-s', ...
    'DisplayName', 'Recall (Complex Dataset)')
plot(ieee57_tr_sz, ieee57_fsc_cmplx, '-x', ...
    'DisplayName', '{\itF_1} Score (Complex Dataset)')
legend('show', 'Location', 'southeast')
ax = gca;
ax.XTickLabel = num2str(ax.XTick');
xtickangle(45)
set(gca, 'FontName', FONT, 'Fontsize', FONT_SIZE)
xlabel('Size of Training Dataset', 'FontSize', FONT_SIZE, 'FontName', FONT)
ylabel('Performace Measures (%)', 'FontSize', FONT_SIZE, 'FontName', FONT)
if pdf, save2pdf('ieee57_tr_sz' , h, 600); end