function result = get_SCI_30(state_case)
%initializations for PSAT
    file_name = 'ieee30'%using ieee 30 smart
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
    num_components = 50; % number of components 20line + 3 FACTS
    j = 1;
    sssc_state = ones(Sssc.n, 1);
    while j <= FOM_LENGTH
            %% Inject failures:
            % Transmission lines
            Line.store(1:41, end) = state_case (1:41);
            % FACTS devices
            sssc_state = state_case (42:46);
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
    result = sum(bus_voltages(PQ.bus) > ...
    MIN_VOLTAGE & ...
    bus_voltages(PQ.bus) < MAX_VOLTAGE) / PQ.n;

end