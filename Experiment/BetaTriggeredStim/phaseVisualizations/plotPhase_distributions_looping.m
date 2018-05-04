%% 5-3-2018 - script to plot phase distributions of beta triggered stim signal

%%
%close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\v3';
cd(baseDir);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1},{'m',[0 180],2},{'s',180,3},{'s',270,4},{'m',[90,270],5},{'m',[90,180],6},{'m',[90,270],7},{'m',[90,270],8}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);

gcp; % parallel pool

files = dir('*.mat');

for file = files'
    load(file.name);
    subStrings = split(file.name,'_');
    sid = subStrings{1};
    chan = str2num(subStrings{2});
    
    info = M(sid);
    type = info{1};
    
    if strcmp(type,'m')
        
        desiredF = info{2};
        
        % plot frequency stimulus delivery distribution
        figure
        histogram((f_pos))
        title({['Subject ' num2str(info{3}) '  distribution of frequencies '],[' on the raw fit signal for Phase 1']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        % plot frequency stimulus delivery distribution
        
        %
        figure
        histogram((f_pos_acaus))
        title({['Subject ' num2str(info{3}) '  distribution of frequencies '],[' on the filtered fit signal for Phase 1']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        
        % plot phase distribution
        figure
        histogram(rad2deg(phase_at_0_pos))
        title({['Subject ' num2str(info{3}) '  distribution of phases '],[' on the raw fit signal for Phase 1']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        % bootstrap on raw
        
        degVec = [0:0.5:360];
        [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0_pos));
        title({['Subject ' num2str(info{3}) ' bootstrapped distribution of phases '],[' on the raw fit signal for Phase 1']})
        ylabel('Density Estimate')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        % filtered signal
        
        figure
        histogram(rad2deg(phase_at_0_pos_acaus))
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the filtered fit signal for Phase 1']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        figure
        histogram(rad2deg(phase_at_0_pos(r_square_pos>0.8)));
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the raw fit signal for Phase 1, R^2 > 0.85']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        
        
        figure
        histogram(rad2deg(phase_at_0_pos_acaus(r_square_pos_acaus>0.8)));
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the filtered fit signal for Phase 1, R^2 > 0.8']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        
        figure
        hilbPhasePos0conv = hilbPhasePos0;
        hilbPhasePos0conv(hilbPhasePos0<0) = 2*pi + hilbPhasePos0(hilbPhasePos0<0);
        histogram(rad2deg(hilbPhasePos0conv))
        title({['Subject ' num2str(info{3}) ' distribution of hilbert phases for Phase 2']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(1))
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % plot frequency stimulus delivery distribution
        figure
        histogram((f_neg))
        title({['Subject ' num2str(info{3}) ' distribution of frequencies '],[' on the raw fit signal for Phase 2']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        set(gca,'fontsize',14);
        
        % plot frequency stimulus delivery distribution
        figure
        histogram((f_neg_acaus))
        title({['Subject ' num2str(info{3}) ' distribution of frequencies '],[' on the filtered fit signal for Phase 2']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        set(gca,'fontsize',14);
        
        
        % plot phase distribution
        figure
        histogram(rad2deg(phase_at_0_neg))
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the raw fit signal for Phase 2']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        
        degVec = [0:0.5:360];
        [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0_neg));
        title({['Subject ' num2str(info{3}) ' Bootstrapped distribution of phases '],[' on the raw fit signal for Phase 2']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        
        figure
        histogram(rad2deg(phase_at_0_neg_acaus))
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the filtered fit signal for Phase 2']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        figure
        histogram(rad2deg(phase_at_0_neg(r_square_neg>0.8)));
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the raw fit signal for Phase 2, R^2 > 0.8']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        
        figure
        histogram(rad2deg(phase_at_0_neg_acaus(r_square_neg_acaus>0.8)));
        title({['Subject ' num2str(info{3}) ' distribution of phases '],[' on the filtered fit signal for Phase 2, R^2 > 0.8']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        % hilbert phase
        figure
        hilbPhaseNeg0conv = hilbPhaseNeg0;
        hilbPhaseNeg0conv(hilbPhaseNeg0<0) = 2*pi + hilbPhaseNeg0(hilbPhaseNeg0<0);
        histogram(rad2deg(hilbPhaseNeg0conv))
        title({['Subject ' num2str(info{3}) ' distribution of hilbet phases for Phase 2']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF(2))
        set(gca,'fontsize',14);
        
        
    elseif strcmp(type,'s')
        
        desiredF = info{2};
        
        
        % plot frequency stimulus delivery distribution
        figure
        histogram((f))
        title({['Subject ' num2str(info{3}) '  distribution of frequencies '],[' on the raw fit signal']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        set(gca,'fontsize',14);
        
        
        % plot frequency stimulus delivery distribution
        figure
        histogram((f_acaus))
        title({['Subject ' num2str(info{3}) '  distribution of frequencies '],[' on the filtered fit signal']})
        ylabel('count')
        xlabel('Frequency in Hz')
        xlim([12 30])
        set(gca,'fontsize',14);
        
        
        % plot phase distribution
        figure
        histogram(rad2deg(phase_at_0))
        title({['Subject ' num2str(info{3}) '  distribution of phases '],[' on the raw fit signal']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',14);
        
        
        degVec = [0:0.5:360];
        [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0));
        title({['Subject ' num2str(info{3}) '  bootstrapped distribution of phases '],[' on the raw fit signal']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',14);
        
        
        figure
        histogram(rad2deg(phase_at_0_acaus))
        title({['Subject ' num2str(info{3}) '  distribution of phases '],[' on the filtered fit signal']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',14);
        
        
        % hilbert phase
        figure
        hilbPhase0conv = hilbPhase0;
        hilbPhase0conv(hilbPhase0<0) = 2*pi + hilbPhase0(hilbPhase0<0);
        histogram(rad2deg(hilbPhase0conv))
        title({['Subject ' num2str(info{3}) '  distribution of hilbert phases ']})
        ylabel('count')
        xlabel('Phase in degrees')
        xlim([0 360])
        vline(desiredF)
        set(gca,'fontsize',14);
        
        
    end
    
end


