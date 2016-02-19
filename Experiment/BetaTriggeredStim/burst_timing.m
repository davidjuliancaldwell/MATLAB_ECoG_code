function [] = burst_timing(bursts)
% modified DJC to look at number of ones

efs = 1.2207e4;
fs = 2.4414e4;

figure

sid = '0b5a2e';

suffix = cell(1,3);
suffix{1} = 'Negative phase of Beta';
suffix{2} = 'Positive phase of Beta';
suffix{3} = 'Null Condition';

for n = 0:2
    ax(n+1) = subplot(3,1,n+1);
    
    burstsM = bursts(:,bursts(5,:)==n);
    beginnings = [burstsM(2,:) 0];
    ends = [0 burstsM(3,:) ];
    
    combined = [ends; beginnings]./fs;
    differences = diff(combined,1,1);
    
    differencesMod = differences(2:(end-1));
    
    switch(n)
        case 0
            binnedBurstsNeg = differencesMod;
        case 1
            binnedBurstsPos = differencesMod;
        case 2
            binnedBurstsNull = differencesMod;
    end
    
    
    histogram(differencesMod(2:end),50);
    title(sprintf('%s', suffix{n+1}));
    
    vline(2)
    
end
linkaxes(ax, 'x');
xlabel('seconds')
ylabel('Total')
subtitle(sprintf('%s - Histogram of length of bursts',sid))


numConds = 3;
pNew = 0.05/numConds;

[pR,hR,statsR] = ranksum(binnedBurstsNeg,binnedBurstsPos,'alpha',pNew)
[hK,pK,k2stat] = kstest2(binnedBurstsNeg,binnedBurstsPos,'alpha',pNew)

[pR,hR,statsR] = ranksum(binnedBurstsNeg,binnedBurstsNull,'alpha',pNew)
[hK,pK,k2stat] = kstest2(binnedBurstsNeg,binnedBurstsNull,'alpha',pNew)

[pR,hR,statsR] = ranksum(binnedBurstsPos,binnedBurstsNull,'alpha',pNew)
[hK,pK,k2stat] = kstest2(binnedBurstsPos,binnedBurstsNull,'alpha',pNew)




end