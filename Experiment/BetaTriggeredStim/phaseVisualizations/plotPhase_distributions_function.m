function [] =  plotPhase_distributions_function(f,phase,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)


% plot frequency stimulus delivery distribution
figure
histogram((f))
title({['Subject ' num2str(subjectNum) ' distribution of frequencies '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Frequency in Hz')
xlim([12 25])
% plot frequency stimulus delivery distribution

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');

end

% plot phase distribution
figure
histogram(rad2deg(phase))
title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end

% bootstrap on ' signalType '

degVec = [0:0.5:360];
[boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase));
title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
ylabel('Density Estimate')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end

% plot ' signalType '  fit > R^2

figure
histogram(rad2deg(phase(r_square>0.7)));
title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > 0.7'],['Channel ' num2str(chan) ]})
ylabel('count')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end

% bootstrap on ' signalType '  > R^2

degVec = [0:0.5:360];
[boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase(r_square>0.7)));
title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > 0.7'],['Channel ' num2str(chan)]})
ylabel('Density Estimate')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end


% R^2 plot
figure
histogram(r_square);
title({['Subject ' num2str(subjectNum) ' R^2 distribution of fits '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
ylabel('Density Estimate')
xlabel('Phase in degrees')
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['rsquare-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['rsquare-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end


end