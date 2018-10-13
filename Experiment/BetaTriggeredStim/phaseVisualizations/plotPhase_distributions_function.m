function [] =  plotPhase_distributions_function(f,phase,rSquare,threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)

ksdensityPlotBool = false;
bootdistPlotBool = false;
polarHistogramBool = true;
plotUnthresh = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if plotUnthresh
    % plot frequency stimulus delivery distribution
    figure
    histogram((f))
    title({['Subject ' num2str(subjectNum) ' distribution of frequencies '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 25])
    % plot frequency stimulus delivery distribution
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot phase distribution
    figure
    histogram(rad2deg(phase))
    title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desiredF)
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['phaseDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % R^2 plot
    figure
    histogram(rSquare);
    title({['Subject ' num2str(subjectNum) ' R^2 distribution of fits '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
    ylabel('Density Estimate')
    xlabel(['R^2 value'])
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['rsquare-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['rsquare-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    if polarHistogramBool
        radVec = deg2rad([0:10:360]);
        figure
        polarhistogram(phase,'binedges',radVec,'FaceColor','white')
        title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ],['Channel ' num2str(chan) ]})
        set(gca,'fontsize',16)
        
    end
    
    if bootdistPlotBool
        degVec = [0:0.5:360];
        [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase));
        title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
        ylabel('Density Estimate')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',16)
        
    end
    
    %% ksdensity plot
    if ksdensityPlotBool
        degVec = [0:1:360];
        figure
        ksdensity_plot(degVec,rad2deg(phase));
        title({['Subject ' num2str(subjectNum) ' kernel density plot '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
        ylabel('Density Estimate')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',16)
        
        if saveIt
            SaveFig(OUTPUT_DIR, sprintf(['kernelDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
            SaveFig(OUTPUT_DIR, sprintf(['kernelDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
        end
        
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numel(phase(rSquare>threshold))
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f(rSquare>threshold)))
    title({['Subject ' num2str(subjectNum) ' distribution of frequencies '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan)]})
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 25])
    % plot frequency stimulus delivery distribution
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    % plot ' signalType '  fit > R^2
    
    figure
    histogram(rad2deg(phase(rSquare>threshold)));
    title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan) ]})
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desiredF)
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['phaseDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    figure
    histogram(rSquare(rSquare>threshold));
    title({['Subject ' num2str(subjectNum) ' R^2 distribution of fits '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
    ylabel('Density Estimate')
    xlabel(['R^2 value'])
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['rsquare-great0-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['rsquare-great0-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    if polarHistogramBool
        radVec = deg2rad([0:10:360]);
        
        figure
        %polarhistogram(phase(rSquare>threshold),'binedges',radVec,'FaceColor','white')
        
        circPlot = circ_plot(phase(rSquare>threshold),'hist',[],20,true,true,'linewidth',2,'color','r');
        title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan) ]})
        set(circPlot,'fontsize',16)
        
    end
    
    if bootdistPlotBool
        
        % bootstrap on ' signalType '  > R^2
        
        degVec = [0:0.5:360];
        [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase(rSquare>threshold)));
        title({['Subject ' num2str(subjectNum) ' bootstrapped distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan)]})
        ylabel('Density Estimate')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',16)
        
        if saveIt
            SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
            SaveFig(OUTPUT_DIR, sprintf(['bootDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
        end
    end
    
    %% ksdensity plot
    if ksdensityPlotBool
        degVec = [0:0.1:360];
        
        % bootstrap on ' signalType '  > R^2
        ksdensity_plot(degVec,rad2deg(phase(rSquare>threshold)));
        title({['Subject ' num2str(subjectNum) ' kernel distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan)]})
        ylabel('Density Estimate')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',16)
        
        if saveIt
            SaveFig(OUTPUT_DIR, sprintf(['kernelDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
            SaveFig(OUTPUT_DIR, sprintf(['kernelDistThresh-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
        end
    end
    
end

end