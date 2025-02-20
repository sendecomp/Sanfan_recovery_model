function output = line_structure(file_name)

DATA_PATH = 'data';

fid = fopen(fullfile(DATA_PATH, append(file_name, '.m')));

tline = fgets(fid);
while ~strncmpi(tline,'Line.con',8)
    tline = fgets(fid);
end
tline = fgets(fid);
idx = 0;
lines = [];
while ~strncmpi(tline,'  ];',4)
    idx = idx + 1;
    cell = textscan(tline,'%d');
    lines(idx,1) = cell{1}(1);
    lines(idx,2) = cell{1}(2);
    tline = fgets(fid);
end
fclose(fid);

for idx = 1 : size(lines, 1)
    output.from(idx) = lines(idx, 1);
    output.to(idx) = lines(idx, 2);
    output.lines{idx} = sprintf('From %.0f To %.0f', ...
        lines(idx, 1), lines(idx, 2));
end
header = sprintf('\tLine #\t|\tFrom Bus\t|\tTo Bus\n');
header = [header, repmat('-', 1, 40), sprintf('\n')];
output.table = [header, ...
    sprintf('\t%.0f\t\t|\t%.0f\t\t\t|\t%.0f\t\n', ...
    [1:idx; lines(:, 1)'; lines(:, 2)'])];

end