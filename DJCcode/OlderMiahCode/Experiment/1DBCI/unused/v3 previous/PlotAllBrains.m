subjids = {'26cb98', '38e116', '4568f4', '30052b', 'fc9643', 'mg', '04b3d5'};

for c = 1:length(subjids)
    sid = subjids{c};
    load(['d:\research\code\output\1DBCI\cache\fig_overall.' sid '.mat']);
    
    figure;
    PlotCortex(sid);
    PlotElectrodes(sid, Montage.MontageTokenized);
    
    if c <= 5
        view(90,0);
    else
        view(270,0);
    end
    
    title(sid);
    SaveFig(fullfile(pwd, 'temp'), sid, 'png');
end
