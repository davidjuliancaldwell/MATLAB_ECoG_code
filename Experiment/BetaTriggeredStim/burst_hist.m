function [] = burst_hist(bursts)
% this function is designed to take a burst table (in the case of ecb43e,
% where there are 4 conditions, and plot a histogram of the number of
% bursts in each size, binned.

figure
for n = 0:3
    ax(n+1) = subplot(4,1,n+1);
    hist(bursts(4, bursts(5,:)==n),30);
    title(sprintf('condition %d', n));
end
linkaxes(ax, 'x');
xlabel('Number of pulses in train');
ylabel('Number of instances of given number of pulses');

end