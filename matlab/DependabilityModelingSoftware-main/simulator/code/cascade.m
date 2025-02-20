function failure_seq = cascade(file_name, initial_failures)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function returns a sequence of transmission lines that overload and
% fail subsequent to given failure cases.
% INPUTS:
%  -file_name: Name of the PSAT .m data file without '.m'
%  -initial_failure: An array of structures with following fields: 
%       'line', 'facts', 'pmu', 'ds_facts', 'pmu_ds', and 'ds'
%   where each element represents a failure case and index(ices) inside
%   corresponding fields show the components that are killed in that
%   failure case. For example, a failure case in which lines 3 and 7 and
%   pmu 2 are killed, is represented by a structure whose 'line' field
%   equals {[3, 7]} and 'pmu' field equals {[2]}. Other fields are empty.
% OUTPUT:
%  -failure_seq: An array of structures similar to initial_failure. Each
%   field is a cell with different number of elements. Each element is an
%   array of corresponding components failed at that instance. There are
%   two additional fields: csi and anve that represent service indices.
%
% A text file, named '<INPUT_FILE_NAME>.txt' will also be generated in the
% failure_seq folder, in which each line represents a sequence of failures
% occured as a result of a failure case. An example is:
% line[4] pmu[1] > line[1] facts[3] > line[2] ~
% where line 4 and pmu 1 are killed (failure case) at t=0; then line 1
% overloaded and facts device 3 disabled at t=1; and finally line 2
% overloaded and tripped at t=2; at this time cascade terminated.
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% First version:     April 23, 2015
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define Constants
DATA_PATH = 'data';
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
SEQ_LENGTH = 15;
%Seconds PMU clock can be unlocked before not accepted by PDC
%Absolute arrival time, assumes 100ms window and 1µs drift per 1s 
ABSOLUTE_MAX_NOISE_S = 100000;    

%% Initialize PSAT
warning off all
initpsat
clpsat.mesg = 0; % Do not display message on MATLAB workspace
clpsat.readfile = 0; % Do not read input before running power flow
copyfile(fullfile(DATA_PATH, append(file_name, '.m')), pwd);
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
fid = fopen(fullfile(FAILURE_SEQ_PATH, append(file_name, '.txt')), 'w');

%% Initialize failure sequences
fields = {'line', 'facts', 'pmu', 'ds_facts', 'pmu_ds', 'ds', 'gps'};
if ~all(isfield(initial_failures, fields))
    closepsat
    if (fid ~= 0 && fid ~= 1)
        fclose(fid);
    end
    error('Missing fields in initial failures structure');
end
failure_seq = struct();
fprintf('Constructing failure cases ...\n');
for i = 1:length(initial_failures)
    for j = 1:length(fields)
        failure_seq(i).(fields{j}) = [{[]}, ...
            initial_failures(i).(fields{j}), ...
            repmat({[]}, 1, SEQ_LENGTH - 2)];
    end
    %Adds failing GPS links with time failed > ABSOLUTE_MAX_NOISE as failed
    %PMUs to beginning of failure_seq
%     if (~isempty(failure_seq(i).gps{2}))
%         for k = 1: length(failure_seq(i).gps{2}.device{1})
%             if failure_seq(i).gps{2}.noise_duration >= ABSOLUTE_MAX_NOISE_S && ...
%                     ~ismember(failure_seq(i).gps{2}.device{1}(k), ...
%                     failure_seq(i).pmu{2})
%                 failure_seq(i).pmu{2} = [failure_seq(i).pmu{2}, failure_seq(i).gps{2}.device{1}(k)];
% 
%             end
%         end
%     end
end

%% Load neural network
try
    load(fullfile(NN_PATH, append(file_name, '.mat')))
catch er
    warning on all
    warning(er.message)
    warning off all
end

%% Simulate failure cases
crash_cnt = 0;
fprintf('Simulating failure cases ...\n');
for i = 1:length(failure_seq)
    formatSpec = 'Simulating sequence %d of %d.\n';
    fprintf(formatSpec,i,length(failure_seq))
    j = 1;
    sssc_state = ones(Sssc.n, 1);
    while j <= SEQ_LENGTH
        %% Terminate this sequence if needed
        if j > 1 && isempty(failure_seq(i).line{j}) && ...
                isempty(failure_seq(i).facts{j}) && ...
                isempty(failure_seq(i).pmu{j}) && ...
                isempty(failure_seq(i).ds_facts{j}) && ...
                isempty(failure_seq(i).pmu_ds{j}) && ...
                isempty(failure_seq(i).ds{j}) %&& ...
%                 isempty(failure_seq(i).gps{j})
            failure_seq(i).sv.bus = [ ...
                failure_seq(i).sv.bus ...
                repmat(failure_seq(i).sv.bus(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.line = [ ...
                failure_seq(i).sv.line ...
                repmat(failure_seq(i).sv.line(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.pmu = [failure_seq(i).sv.pmu ...
                repmat(failure_seq(i).sv.pmu(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.pmu_ds = [...
                failure_seq(i).sv.pmu_ds ...
                repmat(failure_seq(i).sv.pmu_ds(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.facts = [failure_seq(i).sv.facts ...
                repmat(failure_seq(i).sv.facts(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.ds_facts = [...
                failure_seq(i).sv.ds_facts ...
                repmat(failure_seq(i).sv.ds_facts(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
            failure_seq(i).sv.ds = [failure_seq(i).sv.ds ...
                repmat(failure_seq(i).sv.ds(j - 1), 1, ...
                SEQ_LENGTH - j + 1)];
%             failure_seq(i).sv.gps = [ ...
%                 failure_seq(i).sv.gps ...
%                 repmat(failure_seq(i).sv.gps(j - 1), 1, ...
%                 SEQ_LENGTH - j + 1)];
            if fid ~= 0, fprintf(fid, '.\n'); end
            break
        end
        
        %% Inject faults
        % Transmission lines
        Line.store([failure_seq(i).line{1:j}], end) = 0;
        % FACTS devices
        sssc_state([failure_seq(i).facts{1:j}]) = 0;
        % Communication from decision support to FACTS devices
        sssc_state([failure_seq(i).ds_facts{1:j}]) = 0;
        % PMU devices
        Pmu.store([failure_seq(i).pmu{1:j}], end) = 0;
        % Communication from PMU devices to decision support
        Pmu.store([failure_seq(i).pmu_ds{1:j}] - Sssc.n, end) = 0;
        
        %% Propagate faults to next time step manually
        % Kill SSSC devices that are installed on tripped lines if not
        % killed before
        tripped_lines = failure_seq(i).line{j};
        for k = 1:length(tripped_lines)
            killed_sssc = find(Sssc.con(:, 1) == tripped_lines(k));
            for l = 1:length(killed_sssc)
                if all([failure_seq(i).facts{1:j}] ~= killed_sssc(l))
                    failure_seq(i).facts{j + 1} = ...
                        [failure_seq(i).facts{j + 1} killed_sssc(l)];
                end
            end
        end
        
        %Kill PMUs that have been unlocked from GPS clock longer than
        %arrival window if not already killed
        if ~isempty(failure_seq(i).gps{j})
            for k = 1:length(failure_seq(i).gps{j}.device{1})
                if failure_seq(i).gps{j}.noise_duration >= ...
                    ABSOLUTE_MAX_NOISE_S && ...
                    ~ismember(failure_seq(i).gps{j}.device{1}(k), ...
                    failure_seq(i).pmu{j})
                failure_seq(i).pmu{j + 1} = [failure_seq(i).pmu{j + 1}, ... 
                    failure_seq(i).gps{j}.device{1}(k)];
                end
            end
        end
        %% Print results
        if j > 2 && fid ~= 0
            fprintf(fid, '> ');
        end
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
            if ~isempty(failure_seq(i).gps{j})
                fprintf(fid, 'gps[%s] ', ...
                    num2str(failure_seq(i).gps{j}.device{1}));
            end
        end
        
        %% Simulate smart grid
        try
            %% Simulate power system
            Sssc.store(:, 6) = sssc_default_settings .* sssc_state;
            runpsat pf
            bus_voltages = DAE.y(1+Bus.n:2*Bus.n);
            bus_phases = DAE.y(1:Bus.n);
            [line_flows, ~, ~, ~] = fm_flows('bus');
            line_flows(isnan(line_flows)) = 0;
            
            %% Simulate action of decision support
            if isempty([failure_seq(i).ds{1:j}]) && exist('Net', 'var')
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
                Sssc.store(:, 6) = sssc_settings .* sssc_state;
                runpsat pf
                bus_voltages = DAE.y(1+Bus.n:2*Bus.n);
                bus_phases = DAE.y(1:Bus.n);
                [line_flows, ~, ~, ~] = fm_flows('bus');
                line_flows(isnan(line_flows)) = 0;
            end
            
            %% Record state variables
            failure_seq(i).sv.bus{j} = bus_voltages;
            failure_seq(i).sv.line{j} = line_flows;
            failure_seq(i).sv.pmu{j} = Pmu.store(:, end);
            %%%% DANILO EDIT 
            % failure_seq(i).sv.pmu{j} = failure_seq(i).sv.pmu{j}(:,end);
            failure_seq(i).sv.pmu_ds{j} = ...
                isempty([failure_seq(i).pmu_ds{1:j}]);
            failure_seq(i).sv.ds_facts{j} = ...
                isempty([failure_seq(i).ds_facts{1:j}]);
            failure_seq(i).sv.facts{j} = sssc_state;
            % exp(-RMSE) as a measure of observability of the decision
            % support
            if isempty([failure_seq(i).ds{1:j}]) && exist('Net', 'var')
                failure_seq(i).sv.ds{j} = exp(-(...
                    sqrt(sum((pmu_readings.bus_voltages-bus_voltages) ...
                    .^ 2) / Bus.n) + ...
                    sqrt(sum((pmu_readings.line_flows-line_flows) ...
                    .^ 2) / Line.n)) / 2);
            else
                failure_seq(i).sv.ds{j} = 0;
            end
            
            %% Determine overloaded lines and failed components
            overloaded_lines = find(abs(line_flows) > line_flow_limits)';
            % Sort based on severity of overload (worst case first)
            [~, sorted_idx] = sort((abs(line_flows(overloaded_lines)) - ...
                line_flow_limits(overloaded_lines)) ./ ...
                line_flow_limits(overloaded_lines), 'descend');
            overloaded_lines = overloaded_lines(sorted_idx);
            if ~isempty(overloaded_lines)
                failure_seq(i).line{j + 1} = overloaded_lines(1);
            end
            % % % % % % % % % % % %    TEMPORARY    % % % % % % % % % % % %
            % Kill PMU if it is installed on a bus at outage
            outage_buses = find(abs(bus_voltages) < MIN_VOLTAGE | ...
                abs(bus_voltages) > MAX_VOLTAGE);
            for k = 1:length(outage_buses)
                killed_pmu = find(Pmu.con(:, 1) == outage_buses(k));
                for l = 1:length(killed_pmu)
                    if all([failure_seq(i).pmu{1:j}] ~= killed_pmu(l))
                        failure_seq(i).pmu{j + 1} = ...
                            [failure_seq(i).pmu{j + 1} killed_pmu(l)];
                    end
                end
            end
            % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
        catch er
            %% Handle cases that PSAT cannot simulate
            switch er.identifier
                case 'MATLAB:badsubscript'
                    if fid == 1
                        fprintf('\nSimulation stopped\n');
                    end
                otherwise
                    rethrow(er)
            end
            if j < 3, crash_cnt = crash_cnt + 1; end
            if fid ~= 0, fprintf(fid, '~\n'); end
            
            failure_seq(i).sv.line{j} = failure_seq(i).sv.line{end};
            failure_seq(i).sv.line{j}(failure_seq(i).line{j}) = 0;
            failure_seq(i).sv.pmu{j} = failure_seq(i).sv.pmu{end};
            failure_seq(i).sv.pmu{j}(failure_seq(i).pmu{j}) = 0;
            failure_seq(i).sv.pmu{j+1} = failure_seq(i).sv.pmu{end};
            failure_seq(i).sv.pmu{j+1}(failure_seq(i).pmu{j+1}) = 0;
            failure_seq(i).sv.facts{j} = failure_seq(i).sv.facts{end};
            failure_seq(i).sv.facts{j}(failure_seq(i).facts{j}) = 0;
            failure_seq(i).sv.facts{j+1} = failure_seq(i).sv.facts{end};
            failure_seq(i).sv.facts{j+1}(failure_seq(i).facts{j+1}) = 0;
            failure_seq(i).sv.ds{j} = failure_seq(i).sv.ds{end};
            failure_seq(i).sv.ds{j}([failure_seq(i).ds{j:end}]) = 0;
            
            failure_seq(i).sv.bus = [ ...
                failure_seq(i).sv.bus ...
                repmat(failure_seq(i).sv.bus(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.bus))];
            failure_seq(i).sv.line = [ ...
                failure_seq(i).sv.line ...
                repmat(failure_seq(i).sv.line(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.line))];
            failure_seq(i).sv.pmu = [failure_seq(i).sv.pmu ...
                repmat(failure_seq(i).sv.pmu(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.pmu))];
            failure_seq(i).sv.pmu_ds = [...
                failure_seq(i).sv.pmu_ds ...
                repmat(failure_seq(i).sv.pmu_ds(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.pmu_ds))];
            failure_seq(i).sv.facts = [failure_seq(i).sv.facts ...
                repmat(failure_seq(i).sv.facts(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.facts))];
            failure_seq(i).sv.ds_facts = [...
                failure_seq(i).sv.ds_facts ...
                repmat(failure_seq(i).sv.ds_facts(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.ds_facts))];
            failure_seq(i).sv.ds = [failure_seq(i).sv.ds ...
                repmat(failure_seq(i).sv.ds(end), 1, ...
                SEQ_LENGTH - length(failure_seq(i).sv.ds))];
            break % Skip to the next failure case
        end
        j = j + 1;
    end
    Line.store(:, end) = ones(Line.n, 1);
    Pmu.store(:, end) = ones(Pmu.n, 1);
end

%% Save output and clean
fprintf('%d cases crashed out of %d failure cases.\n', crash_cnt, ...
    length(failure_seq));
save(fullfile(FAILURE_SEQ_PATH,append(file_name,'.mat')),'failure_seq');
delete(append(file_name, '.m'));
rmpath(LIB_PATH)
closepsat
if (fid ~= 0 && fid ~= 1)
    fclose(fid);
end
warning on all

end