figure
for n = 0:3
    ax(n+1) = subplot(4,1,n+1);
    hist(bursts(4, bursts(5,:)==n),30);
end
linkaxes(ax, 'x');