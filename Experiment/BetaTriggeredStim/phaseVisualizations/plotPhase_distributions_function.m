function [] =  plotPhase_distributions_function(f,phase,r_square,desiredF,sid,subjectNum,chan,type,OUTPUT_DIR,saveIt)


% plot frequency stimulus delivery distribution
figure
histogram((f))
title({['Subject ' num2str(subjectNum) ' distribution of frequencies '],[' on the raw fit signal for Phase 1'],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Frequency in Hz')
xlim([12 30])
% plot frequency stimulus delivery distribution

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF, sid, chan,type), 'png','-r600');
end

% plot phase distribution
figure
histogram(rad2deg(phase))
title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the raw fit signal for Phase 1'],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF, sid, chan,type), 'png','-r600');
end

% bootstrap on raw

degVec = [0:0.5:360];
[boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase));
title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the raw fit signal for Phase 1'],['Channel ' num2str(chan)]})
ylabel('Density Estimate')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%s-sid-%s-chan-%d-type-%s'],desiredF, sid, chan,type), 'png','-r600');
end

% plot raw fit > R^2

figure
histogram(rad2deg(phase(r_square>0.7)));
title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the raw fit signal for Phase 1, R^2 > 0.7'],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%s-sid-%s-chan-%d-type-%s'],desiredF,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%s-sid-%s-chan-%d-type-%s'],desiredF, sid, chan,type), 'png','-r600');
end

% bootstrap on raw > R^2

degVec = [0:0.5:360];
[boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase(r_square>0.7)));
title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the raw fit signal for Phase 1, R^2 > 0.7'],['Channel ' num2str(chan)]})
ylabel('Density Estimate')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%s-sid-%s-chan-%d-type-%s'],desiredF,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%s-sid-%s-chan-%d-type-%s'],desiredF, sid, chan,type), 'png','-r600');
end


end