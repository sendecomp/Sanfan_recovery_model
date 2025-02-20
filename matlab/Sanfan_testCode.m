clear all
addpath('D:\matlab\psat\')%get psat
file_name = 'ieee14'%using ieee 14 smart
%initialze ieee14 with 20 line, 3 facts, 3 pmu, 1 ds, 1 physical failure at max, and
%1 software failure at max
initial_failures = initial_failures_sg(20, 3, 3, 1, 1, 1)
%failure_seq = cascade(file_name, initial_failures)
%% Define Constants
FAILURE_SEQ_PATH = 'failure_seq';
NN_PATH = 'nn';
LIB_PATH = 'lib';
addpath(LIB_PATH);
MIN_VOLTAGE = 0.9; % Minimum acceptable voltage for loads (in p.u.)
MAX_VOLTAGE = 1.1; % Maximum acceptable voltage for loads (in p.u.)
FLOW_THRESHOLD = 1.25; % Maximum capacity of lines (in p.u.)
% To override out-of-range outputs of neural network
FACTS_MIN_SETTING = 0;
FACTS_MAX_SETTING = 70;
FOM_LENGTH = 25;
T_E = round(FOM_LENGTH / 10); % Time when initial failures are injected

%% Initialize PSAT
warning off all
initpsat
clpsat.mesg = 0; % Do not display message on MATLAB workspace
clpsat.readfile = 0; % Do not read input before running power flow
runpsat(file_name, 'data'); % Load data file
Settings.pfsolver = 6; % Simple robust method
runpsat pf % Run powr flow analysis
[line_flows_normal, ~, ~, ~] = fm_flows('bus');
sssc_default_settings = Sssc.con(:, 6);
line_flow_limits = FLOW_THRESHOLD * max(ones(Line.n, 1), ...
    abs(line_flows_normal));

%% Specify output 
% fid:
%-----
% 0: No text output
% 1: Print output to the workspace
% fopen('OUTPUT_FILE_NAME', 'w'): Print output to specified file
fid = fopen(fullfile(FAILURE_SEQ_PATH, [file_name, '.txt']), 'w');

%% Initialize failure sequences
fields = {'line', 'facts', 'pmu', 'ds_facts', 'pmu_ds', 'ds'};
if ~all(isfield(initial_failures, fields))
    closepsat
    if (fid ~= 0 && fid ~= 1)
        fclose(fid);
    end
    error('Missing fields in initial failures structure');
end
failure_seq = struct();
fprintf('Constructing failure cases ...\n');
for i = 1 : length(initial_failures)
    for j = 1 : length(fields)
        failure_seq(i).(fields{j}) = [repmat({[]}, 1, T_E - 1), ...
            initial_failures(i).(fields{j}), ...
            repmat({[]}, 1, FOM_LENGTH - T_E)];
    end
end

%% Load neural network
try
    load(fullfile(NN_PATH, [file_name, '.mat']))
catch er
    warning on all
    warning(er.message)
    warning off all
end

%% Simulate failure cases
crash_cnt = 0;
fprintf('Simulating failure cases ...\n');
for i = 1 : length(failure_seq)
    j = 1;
    while j <= FOM_LENGTH
        if fid ~= 0
            if ~isempty(failure_seq(i).line{j})
                fprintf(fid, 'line[%s] ', ...
                    num2str(failure_seq(i).line{j}));
            end
            if ~isempty(failure_seq(i).facts{j})
                fprintf(fid, 'facts[%s] ', ...
                    num2str(failure_seq(i).facts{j}));
            end
            if ~isempty(failure_seq(i).pmu{j})
                fprintf(fid, 'pmu[%s] ', ...
                    num2str(failure_seq(i).pmu{j}));
            end
            if ~isempty(failure_seq(i).ds_facts{j})
                fprintf(fid, 'ds_facts[%s] ', ...
                    num2str(failure_seq(i).ds_facts{j}));
            end
            if ~isempty(failure_seq(i).pmu_ds{j})
                fprintf(fid, 'pmu_ds[%s] ', ...
                    num2str(failure_seq(i).pmu_ds{j}));
            end
            if ~isempty(failure_seq(i).ds{j})
                fprintf(fid, 'ds[%s] ', ...
                    num2str(failure_seq(i).ds{j}));
            end
        end
        
        try
            %% Simulate power system
            Sssc.store(:, 6) = sssc_default_settings;
            runpsat pf
            bus_voltages = DAE.y(1+Bus.n : 2*Bus.n);
            bus_phases = DAE.y(1 : Bus.n);
            [line_flows, ~, ~, ~] = fm_flows('bus');
            
            %% Simulate action of decision support
            if isempty(failure_seq(i).ds{j}) && exist('Net', 'var')
                % Decision support is functional
                pmu_readings = pmu_estimate(Bus, bus_voltages, ...
                    bus_phases, Line, line_flows, Pmu, Sssc);
                % TODO - Use bus voltages as well as line flows on state
                % estimation
                sssc_settings = Net(pmu_readings.line_flows);
                sssc_settings(sssc_settings < FACTS_MIN_SETTING) = ...
                    FACTS_MIN_SETTING;
                sssc_settings(sssc_settings > FACTS_MAX_SETTING) = ...
                    FACTS_MAX_SETTING;
                Sssc.store(:, 6) = sssc_settings;
                runpsat pf
                bus_voltages = DAE.y(1+Bus.n : 2*Bus.n);
                bus_phases = DAE.y(1 : Bus.n);
                [line_flows, ~, ~, ~] = fm_flows('bus');
            end
            
            %% Record FoMs
            failure_seq(i).csi(j) = sum(bus_voltages(PQ.bus) > ...
                MIN_VOLTAGE & ...
                bus_voltages(PQ.bus) < MAX_VOLTAGE) / PQ.n;
            failure_seq(i).anve(j) = 1 - ...
                sum(abs(1 - bus_voltages(PQ.bus))) / PQ.n;
            
            %% Specify overloaded line
            overloaded_lines = find(abs(line_flows) > line_flow_limits)';
            % Sort based on severity of overload (worst case first)
            [~, sorted_idx] = sort((abs(line_flows(overloaded_lines)) - ...
                line_flow_limits(overloaded_lines)) ./ ...
                line_flow_limits(overloaded_lines), 'descend');
            overloaded_lines = overloaded_lines(sorted_idx);
            if ~isempty(overloaded_lines)
                failure_seq(i).line{j} = overloaded_lines(1);
                if fid ~= 0
                    fprintf(fid, '> ');
                    fprintf(fid, '%d ', overloaded_lines(1));
                end
            elseif j > T_E
                if fid ~= 0, fprintf(fid, '.\n'); end
                failure_seq(i).csi = [failure_seq(i).csi ...
                    repmat(failure_seq(i).csi(j), ...
                    1, FOM_LENGTH - length(failure_seq(i).csi))];
                failure_seq(i).anve = [failure_seq(i).anve ...
                    repmat(failure_seq(i).anve(j), ...
                    1, FOM_LENGTH - length(failure_seq(i).anve))];
                break % Terminate this sequence and skip to the next case
            end

            %% Inject failures:
            % Transmission lines
            Line.store([failure_seq(i).line{1 : j}], end) = 0;
            % FACTS devices
            Sssc.store([failure_seq(i).facts{1 : j}], end) = 0;
            % Communication from decision support to FACTS devices
            Sssc.store([failure_seq(i).ds_facts{j}], end) = 0;
            % PMU devices
            Pmu.store([failure_seq(i).pmu{1 : j}], end) = 0;
            % Communication from PMU devices to decision support
            Pmu.store([failure_seq(i).pmu_ds{1 : j}], end) = 0;
        catch er
            %% Handle cases that PSAT cannot simulate
            switch er.identifier
                case 'MATLAB:badsubscript'
                    if fid == 1
                        fprintf('\nSimulation stopped\n');
                    end
                otherwise
                     warning on all
                     warning(er.message);
                     warning off all
            end
            crash_cnt = crash_cnt + 1;
            if fid ~= 0, fprintf(fid, '~\n'); end
%            failure_seq(i).(csi) = 0
%            failure_seq(i).csi = [failure_seq(i).csi ...
%                zeros(1, FOM_LENGTH - length(failure_seq(i).csi))];
%            failure_seq(i).anve = [failure_seq(i).anve ...
%                zeros(1, FOM_LENGTH - length(failure_seq(i).anve))];
            break % Skip to the next failure case
        end
        j = j + 1;
    end
    Line.store(:, end) = ones(Line.n, 1);
    Sssc.store(:, end) = ones(Sssc.n, 1);
    Pmu.store(:, end) = ones(Pmu.n, 1);
end

%% Save output and clean
fprintf('%d cases crashed out of %d failure cases.\n', crash_cnt, ...
    length(failure_seq));
save(fullfile(FAILURE_SEQ_PATH, [file_name '.mat']), 'failure_seq');
rmpath(LIB_PATH)
closepsat
if (fid ~= 0 && fid ~= 1)
    fclose(fid);
end
