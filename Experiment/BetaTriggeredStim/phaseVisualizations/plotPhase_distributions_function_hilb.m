function [] =  plotPhase_distributions_function_hilb(phase,desiredF,sid,subjectNum,chan,type,phaseInt,OUTPUT_DIR,saveIt)

% plot phase distribution
figure
histogram(rad2deg(phase))
title({['Subject ' num2str(subjectNum) '  distribution of phases '],[' on the raw fit signal for Phase 1'],['Channel ' num2str(chan)]})
ylabel('count')
xlabel('Phase in degrees')
xlim([0 360])
vline(desiredF)

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%s-sid-%s-chan-%d-type-%s'],phaseInt,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%s-sid-%s-chan-%d-type-%s'],phaseInt, sid, chan,type), 'png','-r600');
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
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%s-sid-%s-chan-%d-type-%s'],phaseInt,sid, chan,type), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['bootDist-phase-%s-sid-%s-chan-%d-type-%s'],phaseInt, sid, chan,type), 'png','-r600');
end



end