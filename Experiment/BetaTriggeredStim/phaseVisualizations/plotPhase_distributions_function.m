function [] =  plotPhase_distributions_function(f,phase,rSquare,threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic)

ksdensityPlotBool = false;
bootdistPlotBool = false;
polarHistogramBool = true;

if numel(phase(rSquare>threshold))
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f(rSquare>threshold)))
    title({['Subject ' num2str(subjectNum) ' distribution of frequencies '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan)]})
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 20])
    % plot frequency stimulus delivery distribution
    set(gca,'fontsize',16)
    
    if saveIt
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
        SaveFig(OUTPUT_DIR, sprintf(['freqDist-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
    end
    
    % plot ' signalType '  fit > R^2
    
    figure
    %histogram(rad2deg(phase(rSquare>threshold)));
    histogram(rad2deg(phase(rSquare>threshold)));
    
    %title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ' R^2 > ' num2str(threshold)],['Channel ' num2str(chan) ]})
    title({['Subject ' num2str(subjectNum) ' distribution of phases '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176) ],['Channel ' num2str(chan) ]})
    
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
    histogram(rSquare(rSquare>0));
    title({['Subject ' num2str(subjectNum) ' R^2 distribution of fits '],[' on the ' signalType ' fit signal for Phase ' num2str(desiredF) char(176)],['Channel ' num2str(chan)]})
    ylabel('count')
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
        [peakPhase,peakStd,peakLength,circularTest]= phase_circstats_calc(phase(rSquare>threshold),'testStatistic',testStatistic);
        
        str = {['mean phase of delivery = ' num2str(round(rad2deg(peakPhase))) char(176)],...
            ['vector length = ' num2str(round(peakLength,2)) ],...
            ['standard deviation = ' num2str(round(rad2deg(peakStd))) char(176) ]};
          %  ['test statistic = ' num2str(circularTest)]};
        annot = annotation('textbox',[0 0 .5 .5],'String',str,'FitBoxToText','on');
        annot.EdgeColor = 'none';
        annot.FontSize = 16;
        
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