clear all
addpath('D:\matlab\psat\')
file_name = 'ieee14'
MIN_VOLTAGE = 0.9; % Minimum acceptable voltage for loads (in p.u.)
MAX_VOLTAGE = 1.1; % Maximum acceptable voltage for loads (in p.u.)
FLOW_THRESHOLD = 1.25; % Maximum capacity of lines (in p.u.)
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
Sssc.store(:, 6) = sssc_default_settings;
runpsat pf
bus_voltages = DAE.y(1+Bus.n : 2*Bus.n);
bus_phases = DAE.y(1 : Bus.n);
[line_flows, ~, ~, ~] = fm_flows('bus');