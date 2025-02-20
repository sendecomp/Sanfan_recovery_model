function output = pmu_structure(file_name)

DATA_PATH = 'data';

fid = fopen(fullfile(DATA_PATH, append(file_name, '.m')));

tline = fgets(fid);
while ~strncmpi(tline,'Pmu.con',7)
    tline = fgets(fid);
end
tline = fgets(fid);
idx = 0;
bus = [];
while ~strncmpi(tline,'  ];',4)
    idx = idx + 1;
    cell = textscan(tline,'%d');
    bus(idx) = cell{1}(1);
    tline = fgets(fid);
end
fclose(fid);

for idx = 1 : length(bus)
    output.bus(idx) = bus(idx);
    output.buses{idx} = sprintf('Bus %.0f', bus(idx));
end
header = sprintf('\tPMU #\t|\tBus\n');
header = [header, repmat('-', 1, 23), sprintf('\n')];
output.table = [header, ...
    sprintf('\t%.0f\t\t|\t%.0f\t\n', ...
    [1:idx; bus])];

end