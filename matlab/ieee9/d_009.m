Bus.con = [ ... 
  1  16.5  1  0  4  1;
  2  18  1  0  5  1;
  3  13.8  1  0  3  1;
  4  230  1  0  2  1;
  5  230  1  0  2  1;
  6  230  1  0  2  1;
  7  230  1  0  2  1;
  8  230  1  0  2  1;
  9  230  1  0  2  1;
 ];

SW.con = [ ...
   1 100.0   1.00  1.06000  0.00000  0.00000  0.00000 1.1 0.9  2.32400 1 1 1;
  ];

Sssc.con = [ ... 
  4   5  100.00  1.00  60  62   0.005  0.6  -0.6  1  10  50  1;
  ];

Pmu.con = [ ... 
  4   1.00  60  0.05  0.05  1;
  6   1.00  60  0.05  0.05  1;
  8   1.00  60  0.05  0.05  1;
  ];

Line.con = [ ... 
  9  8  100  230  60  0  0  0.0119  0.1008  0.209  0  0  0  0  0  1;
  7  8  100  230  60  0  0  0.0085  0.072  0.149  0  0  0  0  0  1;
  9  6  100  230  60  0  0  0.039  0.17  0.358  0  0  0  0  0  1;
  7  5  100  230  60  0  0  0.032  0.161  0.306  0  0  0  0  0  1;
  5  4  100  230  60  0  0  0.01  0.085  0.176  0  0  0  0  0  1;
  6  4  100  230  60  0  0  0.017  0.092  0.158  0  0  0  0  0  1;
  2  7  100  18  60  0  0.07826087  0  0.0625  0  0  0  0  0  0  1;
  3  9  100  13.8  60  0  0.06  0  0.0586  0  0  0  0  0  0  1;
  1  4  100  16.5  60  0  0.07173913  0  0.0576  0  0  0  0  0  0  1;
 ];

Breaker.con = [ ... 
  4  7  100  230  60  1  1.083  50  1  0;
 ];

Fault.con = [ ... 
  2  100  230  60  1  1.083  0  0.01;
 ];

SW.con = [ ... 
  1  100  16.5  1.04  0  99  -99  1.1  0.9  0.8  1  1  1;
 ];

PV.con = [ ... 
  2  100  18  1.63  1.025  99  -99  1.1  0.9  1  1;
  3  100  13.8  0.85  1.025  99  -99  1.1  0.9  1  1;
 ];

PQ.con = [ ... 
  6  100  230  0.9  0.3  1.2  0.8  0  1;
  8  100  230  1  0.35  1.2  0.8  0  1;
  5  100  230  1.25  0.5  1.2  0.8  0  1;
 ];

Syn.con = [ ... 
  1  100  16.5  60  4  0  0  0.146  0.0608  0  8.96  0  0.0969  0.0969  0  0.31  0  47.28  0  0  0  1  1  0.002  0  0  1  1;
  2  100  18  60  4  0  0  0.8958  0.1198  0  6  0  0.8645  0.1969  0  0.535  0  12.8  0  0  0  1  1  0.002  0  0  1  1;
  3  100  13.8  60  4  0  0  1.3125  0.1813  0  5.89  0  1.2578  0.25  0  0.6  0  6.02  0  0  0  1  1  0.002  0  0  1  1;
 ];

Tg.con = [ ... 
  2  4  1  0.2  10  0  0.1  -0.1  0.04  5  0.04  0.3  1  0.5  1  1.5  1  1.163  0.105  1;
  1  4  1  0.2  10  0  0.1  -0.1  0.04  5  0.04  0.3  1  0.5  1  1.5  1  1.163  0.105  1;
  3  4  1  0.2  10  0  0.1  -0.1  0.04  5  0.04  0.3  1  0.5  1  1.5  1  1.163  0.105  1;
 ];

Exc.con = [ ... 
  1  2  5  -5  20  0.2  0.063  0.35  1  0.314  0.001  0.0039  1.555;
  2  2  5  -5  20  0.2  0.063  0.35  1  0.314  0.001  0.0039  1.555;
  3  2  5  -5  20  0.2  0.063  0.35  1  0.314  0.001  0.0039  1.555;
 ];

Bus.names = {... 
  'Bus 1'; 'Bus 2'; 'Bus 3'; 'Bus 4'; 'Bus 5'; 
  'Bus 6'; 'Bus 7'; 'Bus 8'; 'Bus 9'};

