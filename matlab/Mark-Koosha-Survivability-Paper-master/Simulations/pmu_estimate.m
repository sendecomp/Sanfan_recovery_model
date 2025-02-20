function pmu_readings = pmu_estimate(bus_obj, bus_voltages, bus_phases, ...
    line_obj, line_flows, pmu_obj, sssc_obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function simulates behavior of phasor measurement units (PMU)
% installed on a power system. The power system has to be simulated in PSAT
% first. This function only supports systems on which SSSC devices are
% installed.
% INPUTS:
%  -bus_obj: An object of BUclass from PSAT named Bus
%  -bus_voltages: A column vector of bus voltages
%  -bus_phases: An column vector of bus phases
%  -line_obj: An object of LNclass from PSAT named Line
%  -line_flows: A column vector of line power flows
%  -pmu_obj: An object of PMclass from PSAT named Pmu
%  -sssc_obj: An object of SSclass from PSAT named Sssc
% OUTPUT:
%  -pmu_readings: A structure with two fields:
%    +bus_voltages: A column vector of bus voltages estimated by installed
%     PMU devices
%    +line_flows: A column vector of line power flows estimated by
%     installed PMU devices
%
% Author:            Koosha Marashi
% Email:             km89f@mst.edu
% Last modified:     April 7, 2015
% Copyright (C) SeNDeComp Group, Missouri S&T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NEGLIGIBLE_FLOW = 1e-4;

bus_voltages_est = zeros(bus_obj.n, 1);
line_flows_est = zeros(line_obj.n, 1);
observable_buses = zeros(bus_obj.n, 1);

% Estimate bus voltages
for i = 1 : bus_obj.n
    if any(nonzeros(pmu_obj.bus .* pmu_obj.store(:, end)) ...
            == bus_obj.con(i,1))
        % PMU-installed bus
        bus_voltages_est(i) = bus_voltages(i);
        observable_buses(i) = 1;
    else
        % Not PMU-installed bus
        for j = 1 : line_obj.n
            if line_obj.store(j,1) == bus_obj.con(i, 1)
                %Lines starting from i-th bus
                if any(nonzeros(pmu_obj.bus .* pmu_obj.store(:, end)) ...
                        == line_obj.store(j,2))
                    % A PMU is installed at a bus that is connected to i-th
                    % bus through j-th line
                    bus_voltages_est(i) = ...
                        bus_voltages(line_obj.store(j, 2)) - ...
                        (line_flows(j) / ...
                        bus_voltages(line_obj.store(j, 2))) * ...
                        line_obj.store(j, 8); % Estimate i-th bus voltage
                    observable_buses(i) = 1;
                    break
                elseif abs(line_flows(j)) < NEGLIGIBLE_FLOW && ...
                        line_obj.store(j, end)
                    bus_voltages_est(i) = ...
                        bus_voltages(line_obj.store(j, 2));
                    observable_buses(i) = 1;
                end
            elseif line_obj.store(j,2) == bus_obj.con(i,1)
                % Lines ending at i-th bus
                if any(nonzeros(pmu_obj.bus .* pmu_obj.store(:, end)) ...
                        == line_obj.store(j, 1))
                    % A PMU is installed at a bus that is connected to i-th
                    % bus through j-th line
                    bus_voltages_est(i) = ...
                        bus_voltages(line_obj.store(j, 1)) - ...
                        (line_flows(j) / ...
                        bus_voltages(line_obj.store(j, 1))) * ...
                        line_obj.store(j, 8); % Estimate i-th bus voltage
                    observable_buses(i) = 1;
                    break
                elseif abs(line_flows(j)) < NEGLIGIBLE_FLOW && ...
                        line_obj.store(j, end)
                    bus_voltages_est(i) = ...
                        bus_voltages(line_obj.store(j, 1));
                    observable_buses(i) = 1;
                end
            end
        end
    end
end

% Estimate line flows
for j = 1 : line_obj.n
    if any(nonzeros(pmu_obj.bus .* pmu_obj.store(:, end)) ...
            == line_obj.store(j, 1)) || ...
            any(nonzeros(pmu_obj.bus .* pmu_obj.store(:, end)) ...
            == line_obj.store(j, 2))
        % A PMU is installed at a bus to which j-th line is connected
        line_flows_est(j) = line_flows(j);
    else
        % No PMU is installed at either ends of the j-th line
        if any(j == sssc_obj.line)
            % An SSSC device is installed on j-th line:
            sssc_lines = find(sssc_obj.con(:, 1) == j);
            xcs_Vector = sssc_obj.xcs;
            xcs = xcs_Vector(sssc_lines); % Compensation reactance (effect
            % of series FACTS devices on the lines)
        else
            xcs = 0;
        end
        delta_phase = bus_phases(line_obj.store(j, 1)) - ...
            bus_phases(line_obj.store(j, 2));
        line_flows_est(j) = (bus_voltages_est(line_obj.store(j, 1)) * ...
            bus_voltages_est(line_obj.store(j, 2)) * ...
            sin(delta_phase)) / ...
            (line_obj.store(j,9) - xcs); % Estimate j-th line flow
    end
end

pmu_readings.bus_voltages = bus_voltages_est;
pmu_readings.line_flows = line_flows_est;

end