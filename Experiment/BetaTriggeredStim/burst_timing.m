function [] = burst_timing(bursts)

efs = 1.2207e4;
fs = 2.4414e4;

figure

beginnings = [bursts(2,:) 0];
ends = [0 bursts(3,:) ];

combined = [ends; beginnings];
differences = diff(combined,1,1);

differencesMod = differences(2:(end-1));

hist(differencesMod(2:end),50);
vline(2*fs)


end