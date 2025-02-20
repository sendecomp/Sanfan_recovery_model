function str = comp_name(file_name, comp_type, idx, formatted)

if nargin == 3
    formatted = true;
end

lines = line_structure(file_name);
facts = facts_structure(file_name);
pmu = pmu_structure(file_name);
switch comp_type
    case 'line'
        str = ['L', subscript(sprintf('%.0f-%.0f', ...
            lines.from(idx), lines.to(idx)))];
    case 'facts'
        str = ['F', subscript(sprintf('%.0f-%.0f', ...
            facts.from(idx), facts.to(idx)))];
    case 'pmu'
        str = ['P', subscript(sprintf('%.0f', ...
            pmu.bus(idx)))];
    case 'ds'
        str = 'DS';
end

if formatted
    str = ['\it', str];
else
    str = strrep(str, '_', '');
end