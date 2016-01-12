%% function to look at burst timing of signal and the raw signal around that 
% written by DJC 1-8-2015 

% load bursts table , this is first for 0b5a2e 

load('D:\Output\BetaTriggeredStim\meta\0b5a2e_tables_modDJC')

efs = 1.2207e4;
fs = 2.4414e4;



burst_hist(bursts) 
burst_timing(bursts)


%% this part doesnt work yet!
% burst_signalExtract(bursts,raw)

