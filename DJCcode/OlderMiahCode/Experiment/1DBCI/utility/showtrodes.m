    subjids = {'26cb98', '38e116', '4568f4', '30052b', 'fc9643', 'mg', '04b3d5'};
sid = subjids{3};

load(['d:\research\code\output\1DBCI\cache\fig_overall.' sid '.mat'])
locs = trodeLocsFromMontage(sid, Montage, true);
aplocs = locs;
aplocs(:,1) = abs(aplocs(:,1));
weight = zeros(length(aplocs),1);
weight(bads)=1;
figure;
PlotDotsDirect('tail', aplocs, weight, 'r', [0 1], 10, 'recon_colormap', 1:size(aplocs,1), true);


%% just playing with this

PlotCortex('tail', 'r');

l = size(aplocs, 1);
if (l > 0 && mod(l, 8) == 0)
    for c = 1:4
        switch (c)
            case 1
                t = 1:8;
            case 2
                t = (l-7):l;
            case 3
                t = 1:8:l;
            case 4
                t = 8:8:l;
        end
                
        line (aplocs(t,1), aplocs(t,2), aplocs(t,3), 'Linewidth', 3);
    end
elseif (l < 8)
    warning('strips not yet implemented');
else
    warning('unknown grid type');
end