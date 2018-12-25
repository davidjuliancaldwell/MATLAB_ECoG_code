function [] = plot_brains_peak_func(dataForPPanalysis,subjid,sid,subjectNum,Grid,betaChan,stims,badsTotal,goodEPs,index,saveFig,OUTPUT_DIR)
%% plot differences

epThresholdMin = 25;
epThresholdMax = 1500;

cmap = cbrewer('seq','Purples',40);

w = nan(size(Grid, 1), 1);
for i = 1:64
    if ~any(i==badsTotal) && any(i ==goodEPs)
        mags = 1e6*dataForPPanalysis{i}{index}{1};
        
        mags(mags<epThresholdMin) = nan;
        mags(mags>epThresholdMax) = nan;
        
        label= dataForPPanalysis{i}{index}{4};
        keeps = dataForPPanalysis{i}{index}{5};
        maxLabel = max(unique(label));
        ppMax = nanmean(mags(label ==maxLabel & keeps));
        w(i) = ppMax;
    end
end

clims = [0 max(w)];

figure
set(gcf, 'Units', 'pixels', 'OuterPosition', [286.6000 108.6000 788.0000 645.6000]);

% plot beta channel overlaid
betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);
PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['trigger channel = ' num2str(betaChan)]},'location','southwest');

colormap(cmap);
h = colorbar;
ylabel(h,'Volts (\muV)')
if subjectNum == 8
    title({['Subject 7 Playback'], ['Peak to peak evoked potential magnitude ']})
    
else
    title({['Subject ' num2str(subjectNum)], 'Peak to peak evoked potential magnitude '})
end
set(gca,'fontsize', 14)

if saveFig
    %     SaveFig(OUTPUT_DIR, sprintf(['EP-phase-%d-sid-%s-chan-%d'],typei,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['cortex-EP-phase-1-sid-%s'],sid), 'png','-r300');
    close
end

%% plot differences
cmap = flipud(cbrewer('div','PiYG',40));

w = nan(size(Grid, 1), 1);
for i = 1:64
    if ~any(i==badsTotal) && any(i ==goodEPs)
        mags = 1e6*dataForPPanalysis{i}{1}{1};
        
        mags(mags<epThresholdMin) = nan;
        mags(mags>epThresholdMax) = nan;
        
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
set(gcf, 'Units', 'pixels', 'OuterPosition', [286.6000 108.6000 788.0000 645.6000]);

betaChanPlot = PlotBrainJustDots(subjid,{betaChan},[255, 153, 0]/255,true,800);

PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, cmap, 1:size(Grid, 1), true);

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(subjid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);

leg = legend([stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['stimulation channel'],['stimulation channel'],...
    ['trigger channel = ' num2str(betaChan)]},'location','southwest');
colormap(cmap);
h = colorbar;
if subjectNum == 8
    title({['Subject 7 Playback'], ['Percent Baseline and Test Pulse (>5 stims) EP difference']})
    
else
    title({['Subject ' num2str(subjectNum)], 'Percent Baseline and Test Pulse (>5 stims) EP difference'})
end
ylabel(h,'Percent Difference')
set(gca,'fontsize', 14)

if saveFig
    SaveFig(OUTPUT_DIR, sprintf(['cortex-percentChange-EP-phase-1-sid-%s'],sid), 'png','-r300');
    close
end
end