## Requirements

1. MATLAB 2012b or newer
2. [PSAT 2.1.8](http://faraday1.ucd.ie/psat.html) or newer (not tested on later versions)

## Procedure

1. Generate failure cases using [initial_failures_sg.m](initial_failures_sg.m).
2. Simulate failure cases and generate failure sequences using [cascade_sg.m](cascade_sg.m).
3. Plot results using [plot_surv_attr.m](plot_surv_attr.m).
4. Analyze importance of components in terms of their effect on survivability using [comp_imp.m](comp_imp.m).