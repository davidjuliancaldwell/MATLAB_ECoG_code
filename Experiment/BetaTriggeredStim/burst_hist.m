function [] = burst_hist(sid,bursts)
% this function is designed to take a burst table (in the case of ecb43e,
% where there are a given number of conditions, and plot a histogram of the number of
% bursts in each size, binned.

% modified by DJC 2-10-2016 to consider stats on the burst table 

figure

% for histc
X = 0:15;

suffix = cell(1,3);
suffix{1} = 'Negative phase of Beta';
suffix{2} = 'Positive phase of Beta';
suffix{3} = 'Null Condition';

% kruskal wallis? 
n_max = unique(bursts(5,:));
max_subs = length(n_max);

figure
for n = n_max
    ax(n+1) = subplot(max_subs,1,n+1);
    histogram(bursts(4, bursts(5,:)==n),X);
    title(sprintf('%s', suffix{n+1}));
    numStims = sum(bursts(4,bursts(5,:)==n));
    numTrains = 
    sprintf('number of stimuli for this condition = %d',numStims)
    sprintf(
end
linkaxes(ax, 'x');
xlabel('Number of pulses in train');
ylabel('Total');
subtitle(sprintf('%s - Histogram of number of stimulations in burst',sid))

end