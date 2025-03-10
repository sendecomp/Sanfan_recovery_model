% File generated by PSAT from IEEE/CDF data file.
% ------------------------------------------------------------------------------
% Author:   Federico Milano
% E-mail:   fmilano@thunderbox.uwaterloo.ca
% Web-site: http://thunderbox.uwaterloo.ca/~fmilano
% ------------------------------------------------------------------------------
%  08/19/93 UW ARCHIVE           100.0  1962 W IEEE 14 Bus Test Case

Bus.con = [ ...
   1    1.00  1.06000  0.00000  1  1;
   2    1.00  1.04500 -0.08692  1  1;
   3    1.00  1.01000 -0.22201  1  1;
   4    1.00  1.01900 -0.18029  1  1;
   5    1.00  1.02000 -0.15324  1  1;
   6    1.00  1.07000 -0.24819  1  1;
   7    1.00  1.06200 -0.23335  1  1;
   8    1.00  1.09000 -0.23318  1  1;
   9    1.00  1.05600 -0.26075  1  1;
  10    1.00  1.05100 -0.26354  1  1;
  11    1.00  1.05700 -0.25813  1  1;
  12    1.00  1.05500 -0.26302  1  1;
  13    1.00  1.05000 -0.26459  1  1;
  14    1.00  1.03600 -0.27995  1  1;
  ];

SW.con = [ ...
   1 100.0   1.00  1.06000  0.00000  0.00000  0.00000 1.1 0.9  2.32400 1 1 1;
  ];

PV.con = [ ...
   2 100.0   1.00  0.40000  1.04500  0.50000 -0.40000 1.1 0.9 1  1;
   3 100.0   1.00  0.00000  1.01000  0.40000  0.00000 1.1 0.9 1  1;
   6 100.0   1.00  0.00000  1.07000  0.24000 -0.06000 1.1 0.9 1  1;
   8 100.0   1.00  0.00000  1.09000  0.24000 -0.06000 1.1 0.9 1  1;
  ];

PQ.con = [ ...
   2 100.0   1.00  0.21700  0.12700 1.1 0.9 1  1;
   3 100.0   1.00  0.94200  0.19000 1.1 0.9 1  1;
   4 100.0   1.00  0.47800 -0.03900 1.1 0.9 1  1;
   5 100.0   1.00  0.07600  0.01600 1.1 0.9 1  1;
   6 100.0   1.00  0.11200  0.07500 1.1 0.9 1  1;
   9 100.0   1.00  0.29500  0.16600 1.1 0.9 1  1;
  10 100.0   1.00  0.09000  0.05800 1.1 0.9 1  1;
  11 100.0   1.00  0.03500  0.01800 1.1 0.9 1  1;
  12 100.0   1.00  0.06100  0.01600 1.1 0.9 1  1;
  13 100.0   1.00  0.13500  0.05800 1.1 0.9 1  1;
  14 100.0   1.00  0.14900  0.05000 1.1 0.9 1  1;
  ];

Shunt.con = [ ...
   9 100.0   1.00 60  0.00000  0.19000  1;
  ];

Line.con = [ ...
   1    2  100.00   1.00 60 0   0.0000  0.01938  0.05917  0.05280  0.00000  0.00000 0    0.000    0.000  1;
   1    5  100.00   1.00 60 0   0.0000  0.05403  0.22304  0.04920  0.00000  0.00000 0    0.000    0.000  1;
   2    3  100.00   1.00 60 0   0.0000  0.04699  0.19797  0.04380  0.00000  0.00000 0    0.000    0.000  1;
   2    4  100.00   1.00 60 0   0.0000  0.05811  0.17632  0.03400  0.00000  0.00000 0    0.000    0.000  1;
   2    5  100.00   1.00 60 0   0.0000  0.05695  0.17388  0.03460  0.00000  0.00000 0    0.000    0.000  1;
   3    4  100.00   1.00 60 0   0.0000  0.06701  0.17103  0.01280  0.00000  0.00000 0    0.000    0.000  1;
   4    5  100.00   1.00 60 0   0.0000  0.01335  0.04211  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   4    7  100.00   1.00 60 0   0.0000  0.00000  0.20912  0.00000  0.97800  0.00000 0    0.000    0.000  1;
   4    9  100.00   1.00 60 0   0.0000  0.00000  0.55618  0.00000  0.96900  0.00000 0    0.000    0.000  1;
   5    6  100.00   1.00 60 0   0.0000  0.00000  0.25202  0.00000  0.93200  0.00000 0    0.000    0.000  1;
   6   11  100.00   1.00 60 0   0.0000  0.09498  0.19890  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   6   12  100.00   1.00 60 0   0.0000  0.12291  0.25581  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   6   13  100.00   1.00 60 0   0.0000  0.06615  0.13027  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   7    8  100.00   1.00 60 0   0.0000  0.00000  0.17615  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   7    9  100.00   1.00 60 0   0.0000  0.00000  0.11001  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   9   10  100.00   1.00 60 0   0.0000  0.03181  0.08450  0.00000  0.00000  0.00000 0    0.000    0.000  1;
   9   14  100.00   1.00 60 0   0.0000  0.12711  0.27038  0.00000  0.00000  0.00000 0    0.000    0.000  1;
  10   11  100.00   1.00 60 0   0.0000  0.08205  0.19207  0.00000  0.00000  0.00000 0    0.000    0.000  1;
  12   13  100.00   1.00 60 0   0.0000  0.22092  0.19988  0.00000  0.00000  0.00000 0    0.000    0.000  1;
  13   14  100.00   1.00 60 0   0.0000  0.17093  0.34802  0.00000  0.00000  0.00000 0    0.000    0.000  1;
  ];

Sssc.con = [ ... 
  2   3  100.00  1.00  60  62   0.005  0.6  -0.6  1  10  50  1;
  3   3  100.00  1.00  60  50   0.005  0.6  -0.6  1  10  50  1;
  4   3  100.00  1.00  60  0    0.005  0.6  -0.6  1  10  50  1;
  ];

Pmu.con = [ ... 
  2   1.00  60  0.05  0.05  1;
  6   1.00  60  0.05  0.05  1;
  9   1.00  60  0.05  0.05  1;
  ];

Areas.con = [ ...
   1 0 100.0 0 0 0 0 0;
  ];

Regions.con = [ ...
   1    2 100.0  0.00000  9.99990 0 0 0;
  ];

Bus.names = { ...
  'Bus 1     HV'; 'Bus 2     HV'; 'Bus 3     HV'; 'Bus 4     HV'; 'Bus 5     HV';
  'Bus 6     LV'; 'Bus 7     ZV'; 'Bus 8     TV'; 'Bus 9     LV'; 'Bus 10    LV';
  'Bus 11    LV'; 'Bus 12    LV'; 'Bus 13    LV'; 'Bus 14    LV'};

Areas.names = { ...
  'IEEE14BUS'};

Regions.names = { ...
  'IEEE14IE'};

