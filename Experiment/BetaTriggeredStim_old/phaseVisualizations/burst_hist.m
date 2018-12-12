function [totalFig] = burst_hist(sid,bursts,typeCell,OUTPUT_DIR)
% this function is designed to take a burst table (in the case of ecb43e,
% where there are a given number of conditions, and plot a histogram of the number of
% bursts in each size, binned.

% modified by DJC 2-10-2016 to consider stats on the burst table

% for histc
%X = 0:15;



% kruskal wallis?
n_max = unique(bursts(5,:));
max_subs = length(n_max);
n_iter = [0];

if strcmp(sid,'6')
    n_max = [0,1,3];
    max_subs = length(n_max);
end

if strcmp(sid,'7')
    n_max = [0,1];
    max_subs = length(n_max);
end



totalFig = figure;
totalFig.Units = 'inches';
totalFig.Position = [10.4097 6.3611 7.8333 7.5625];
for n = n_max
    ax(n_iter+1) = subplot(max_subs,1,n_iter+1);
    histogram(bursts(4, bursts(5,:)==n));
    
    title(sprintf('%s%c', typeCell{n+1},char(176)));
    numStims = sum(bursts(4,bursts(5,:)==n));
    
    sprintf('number of stimuli for this condition = %d',numStims)
    set(gca,'FontSize',14)
    n_iter = n_iter+1;
end
%linkaxes(ax, 'x');
xlabel('Number of pulses in train');
ylabel('Total number of pulses');
subtitle(sprintf('Subject %s - number of stimulations in beta burst',sid))
SaveFig(OUTPUT_DIR, sprintf(['burstHist-subj-%s'], sid), 'eps', '-r600');
SaveFig(OUTPUT_DIR, sprintf(['burstHist-subj-%s'], sid), 'png', '-r600');
SaveFig(OUTPUT_DIR, sprintf(['burstHist-subj-%s'], sid), 'svg', '-r600');

end