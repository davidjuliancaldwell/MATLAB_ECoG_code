function [] = plot_brains_peak_func(dataForPPanalysis,subjid,sid,Grid,betaChan,stims,badsTotal,goodEPs,index)
%% plot differences

cmap = cbrewer('seq','Purples',40);

w = nan(size(Grid, 1), 1);
for i = 1:64
    if ~any(i==badsTotal) && any(i ==goodEPs)
        mags = 1e6*dataForPPanalysis{i}{index}{1};
        label= dataForPPanalysis{i}{index}{4};
        keeps = dataForPPanalysis{i}{index}{5};
        ppMax = nanmean(mags(label ==3 & keeps));
        w(i) = ppMax;
    end
end

clims = [0 max(w)];

figure
% plot beta channel overlaid
betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);
PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['beta recording channel = ' num2str(betaChan)]});

colormap(cm);
h = colorbar;
ylabel(h,'Volts (\muV)')
title({sid 'Peak to peak evoked potential magnitude '})
set(gca,'fontsize', 14)

%% plot differences
cmap = flipud(cbrewer('div','PiYG',40));

w = nan(size(Grid, 1), 1);
for i = 1:64
    if ~any(i==badsTotal) && any(i ==goodEPs)
        mags = 1e6*dataForPPanalysis{i}{1}{1};
        label= dataForPPanalysis{i}{1}{4};
        keeps = dataForPPanalysis{i}{1}{5};
        difference = 100*(nanmean(mags(label ==3 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
        if nanmean(mags(label ==0 & keeps)) > 150
            w(i) = difference;
        end
    end
end

clims = [-max(abs(min(w)),abs(max(w))) max(abs(min(w)),abs(max(w)))];

figure
betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);

PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);


leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['beta recording channel = ' num2str(betaChan)]});
colormap(cmap);
h = colorbar;
title({sid 'Percent Baseline and Test Pulse (>5 stims) EP difference'})
ylabel(h,'Percent Difference')
set(gca,'fontsize', 14)
end