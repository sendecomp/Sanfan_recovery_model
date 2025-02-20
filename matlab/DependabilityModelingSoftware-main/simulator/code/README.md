## Requirements

1. MATLAB 2014b or newer
2. [PSAT 2.1.8](http://faraday1.ucd.ie/psat.html) or newer (not tested on later versions)

## Identification

1. Generate failure cases using [initial_failures_sg.m](initial_failures_sg.m) (smart grid version) or [initial_failures.m](initial_failures.m) (power grid version).
2. Simulate failure cases and generate failure sequences using [cascade.m](cascade.m).
3. Extract direct influence matrix using [identify_dep.m](identify_dep.m).

## Prediction (in progress)
