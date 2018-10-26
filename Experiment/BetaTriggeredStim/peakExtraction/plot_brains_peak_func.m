function [] = plot_brains_peak_func(dataForPPanalysis,subjid,sid,subjectNum,Grid,betaChan,stims,badsTotal,goodEPs,index,saveFig)
%% plot differences

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PeaktoPeakEP\plots';

cmap = cbrewer('seq','Purples',40);

w = nan(size(Grid, 1), 1);
for i = 1:64
    if ~any(i==badsTotal) && any(i ==goodEPs)
        mags = 1e6*dataForPPanalysis{i}{index}{1};
        label= dataForPPanalysis{i}{index}{4};
        keeps = dataForPPanalysis{i}{index}{5};
            maxLabel = max(unique(label));
        ppMax = nanmean(mags(label ==maxLabel & keeps));
        w(i) = ppMax;
    end
end

clims = [0 max(w)];

figure
set(gcf, 'Units', 'pixels', 'OuterPosition', [1.0003e+03 611 800.6667 727.3333]);

% plot beta channel overlaid
betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);
PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['beta channel = ' num2str(betaChan)]},'location','southwest');

colormap(cmap);
h = colorbar;
ylabel(h,'Volts (\muV)')
if subjectNum == 8
    title({['Subject 7 Playback'], ['Peak to peak evoked potential magnitude ']})
    
else
    title({['Subject ' num2str(subjectNum)], 'Peak to peak evoked potential magnitude '})
end
set(gca,'fontsize', 14)

% if saveFig
%     %     SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan,type,signalType), 'svg');
%     SaveFig(OUTPUT_DIR, sprintf(['cortex-EP-phase-1-sid-%s'],sid), 'png');
% end

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
set(gcf, 'Units', 'pixels', 'OuterPosition', [1.0003e+03 611 800.6667 727.3333]);

betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);

PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);


leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['beta channel = ' num2str(betaChan)]},'location','southwest');
colormap(cmap);
h = colorbar;
if subjectNum == 8
    title({['Subject 7 Playback'], ['Percent Baseline and Test Pulse (>5 stims) EP difference']})
    
else
    title({['Subject ' num2str(subjectNum)], 'Percent Baseline and Test Pulse (>5 stims) EP difference'})
end
ylabel(h,'Percent Difference')
set(gca,'fontsize', 14)

% if saveFig
%     SaveFig(OUTPUT_DIR, sprintf(['cortex-percentChange-EP-phase-1-sid-%s'],sid), 'png');
% end
end