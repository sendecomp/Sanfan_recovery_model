clear all
addpath('D:\GitHub\Sanfan_recovery_model\matlab\psat\') %get psat
file_name = 'ieee14'%using ieee 14 smart
MIN_VOLTAGE = 0.9; % Minimum acceptable voltage for loads (in p.u.)
MAX_VOLTAGE = 1.1; % Maximum acceptable voltage for loads (in p.u.)
FLOW_THRESHOLD = 1.25; % Maximum capacity of lines (in p.u.)
% default setting for a running FACTS device
FACTS_MIN_SETTING = 0;
FACTS_MAX_SETTING = 70;
FOM_LENGTH = 25;
T_E = round(FOM_LENGTH / 10); % Time when initial failures are injected
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


num_components = 23; % number of components 20line + 3 FACTS

%construct dataspace for each possible state
%All_states = zeros(2^num_components, num_components);
%for i = 0:(2^num_components - 1) 

%following lines are for temperoy testing
All_states = zeros(50, num_components)
for i = 0:50
    binary_string = dec2bin(i, num_components);
    All_states(i + 1, :) = 1-arrayfun(@str2double, binary_string);
end
csi = zeros(length(All_states),1)
anve = zeros(length(All_states),1)
for state_case = 1:length(All_states)
    j = 1;
    sssc_state = ones(Sssc.n, 1);
    if sum(All_states(state_case, 1:20)) <17
                continue;
            end
    while j <= FOM_LENGTH
            %% Inject failures:
            % Transmission lines
            Line.store(1:20, end) = All_states(state_case, 1:20);
            % FACTS devices
            sssc_state = All_states(state_case, 21:23);
            j = j+1;
            try
                %% Simulate power system
                sssc_state = sssc_state.';
                Sssc.store(:, 6) = sssc_default_settings .* sssc_state;
                runpsat pf
                bus_voltages = DAE.y(1+Bus.n : 2*Bus.n);
                bus_phases = DAE.y(1 : Bus.n);
                [line_flows, ~, ~, ~] = fm_flows('bus');
                runpsat pf
            
            catch er
                disp("error case")
                disp(state_case)
            end
    end
    %disp("case")
    %disp(state_case)
    %% Record FoMs
    csi(state_case) = sum(bus_voltages(PQ.bus) > ...
    MIN_VOLTAGE & ...
    bus_voltages(PQ.bus) < MAX_VOLTAGE) / PQ.n;
    anve(state_case) = 1 - ...
    sum(abs(1 - bus_voltages(PQ.bus))) / PQ.n;
    Line.store(:, end) = ones(20, 1);
    Sssc.store(:, end) = ones(3, 1);
end


writematrix(anve, 'anve.txt')
writematrix(csi, 'csi.txt')