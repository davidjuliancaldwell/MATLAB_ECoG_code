function [] = burst_hist(bursts)
% this function is designed to take a burst table (in the case of ecb43e,
% where there are a given number of conditions, and plot a histogram of the number of
% bursts in each size, binned.

% modified by DJC 2-10-2016 to consider stats on the burst table 

figure

% for histc
X = 0:15;

sid = '0b5a2e';

suffix = cell(1,3);
suffix{1} = 'Negative phase of Beta';
suffix{2} = 'Positive phase of Beta';
suffix{3} = 'Null Condition';

% for stats
% pNew = bonferroni corrected
% dont compare to Null as there are no bursts! 
% numConds = 2;
pNew = 0.05;

binnedBurstsNeg = bursts(4,bursts(5,:)==0);
binnedBurstsPos = bursts(4,bursts(5,:)==1);
binnedBurstsNull = bursts(4,bursts(5,:)==2);

figure
plot(binnedBurstsNeg)
hold on
plot(binnedBurstsPos)


[pR,hR,statsR] = ranksum(binnedBurstsNeg,binnedBurstsPos)
[hK,pK,k2stat] = kstest2(binnedBurstsNeg,binnedBurstsPos)
% 
% [pR,hR,statsR] = ranksum(binnedBurstsNeg,binnedBurstsNull,'alpha',pNew)
% [hK,pK,k2stat] = kstest2(binnedBurstsNeg,binnedBurstsNull,'alpha',pNew)
% 
% [pR,hR,statsR] = ranksum(binnedBurstsPos,binnedBurstsNull,'alpha',pNew)
% [hK,pK,k2stat] = kstest2(binnedBurstsPos,binnedBurstsNull,'alpha',pNew)




% kruskal wallis? 
% [p,tbl,stats] = kruskalwallis()


for n = 0:2
    ax(n+1) = subplot(3,1,n+1);
    histogram(bursts(4, bursts(5,:)==n),X);
    title(sprintf('%s', suffix{n+1}));
end
linkaxes(ax, 'x');
xlabel('Number of pulses in train');
ylabel('Total');
subtitle(sprintf('%s - Histogram of number of stimulations in burst',sid))

end