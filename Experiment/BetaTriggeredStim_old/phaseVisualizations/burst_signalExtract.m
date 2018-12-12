%% function to extract signal around burst timing 
% 1-8-2016 DJC
% start with 0b5a2e 

function [] = burst_signalExtract(bursts,signal)
% modified DJC to look at number of ones

efs = 1.2207e4;
fs = 2.4414e4;

figure

for n = 0:2
    ax(n+1) = subplot(3,1,n+1);
    
    burstsM = bursts(:,bursts(5,:)==n);
    beginnings = [burstsM(2,:) 0];
    ends = [0 burstsM(3,:) ];
    
    extractSig = getEpochSignal(signal,beginnings,ends);
    
    
end

xlabel('samples')
ylabel('Total')
subtitle('Histogram of length of bursts')

end