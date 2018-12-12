%% 8-29-2017 - script to plot phase distributions of beta triggered stim signal

%%
%close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseOfDelivery';
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018';
filePath = promptForBCI2000Recording(baseDir);
load(filePath)

type = input('single or multiple phase of delivery? input "s" or "m"\n','s');


gcp;

%%

if strcmp(type,'m')
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f_pos))
    title('Distribution of Frequency of Oscillatory signal for Phase 1')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    % plot frequency stimulus delivery distribution
    
    %
    desired = input('input desired degree of stimulus phase \n');
    
    figure
    histogram((f_pos_acaus))
    title('Distribution of Frequency of Oscillatory signal for acausally filtered signal for Phase 1')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    
    degVec = [0:0.5:360];
    [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0_pos));
    title('Distribution of Phases on the raw fit signal for Phase 1')
    ylabel('Density Estimate')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    % plot phase distribution
    figure
    histogram(rad2deg(phase_at_0_pos))
    title('Bootstrapped distribution of phases on the raw fit signal for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    
    figure
    histogram(rad2deg(phase_at_0_pos_acaus))
    title('Distribution of Phases on the acausally filtered fit signal for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    figure
    histogram(rad2deg(phase_at_0_pos(r_square_pos>0.8)));
    title('Distribution of phase delivery on the raw fit signal for phase 1 >0.8')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    
    
    figure
    histogram(rad2deg(phase_at_0_pos_acaus(r_square_pos_acaus>0.8)));
    title('Distribution of phase delivery on the acausally fit signal for phase 1 >0.8')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    
    figure
    hilbPhasePos0conv = hilbPhasePos0;
    hilbPhasePos0conv(hilbPhasePos0<0) = 2*pi + hilbPhasePos0(hilbPhasePos0<0);
    histogram(rad2deg(hilbPhasePos0conv))
    title('Distribution of Hilbert Phase for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f_neg))
    title('Distribution of Frequency of Oscillatory signal for Phase 2')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f_neg_acaus))
    title('Distribution of Frequency of Oscillatory signal - acausally filtered for Phase 2')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    
    
    
    % plot phase distribution
    figure
    desired = input('input desired degree of stimulus phase \n');
    histogram(rad2deg(phase_at_0_neg))
    title('Distribution of Phases on the raw fit signal for Phase 2')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    degVec = [0:0.5:360];
    [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0_neg));
    title('Bootstrapped distribution of phases on the raw fit signal for Phase 2')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    
    figure
    histogram(rad2deg(phase_at_0_neg_acaus))
    title('Distribution of Phases on the acausally filtered fit signal for Phase 2')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    figure
    histogram(rad2deg(phase_at_0_neg(r_square_neg>0.8)));
    title('Distribution of phase delivery on the raw fit signal for phase 2 >0.8')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    
    
    figure
    histogram(rad2deg(phase_at_0_neg_acaus(r_square_neg_acaus>0.8)));
    title('Distribution of phase delivery on the acausally fit signal for phase 2 >0.8')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    
    % hilbert phase
    figure
    hilbPhaseNeg0conv = hilbPhaseNeg0;
    hilbPhaseNeg0conv(hilbPhaseNeg0<0) = 2*pi + hilbPhaseNeg0(hilbPhaseNeg0<0);
    histogram(rad2deg(hilbPhaseNeg0conv))
    title('Distribution of Hilbert Phase for Phase 2')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    
elseif strcmp(type,'s')
    
    
    
    % plot frequency stimulus delivery distribution
    figure
    histogram((f))
    title('Distribution of Frequency of Oscillatory signal')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    % plot frequency stimulus delivery distribution
    figure
    histogram((f_acaus))
    title('Distribution of Frequency of acausally filtered Oscillatory signal')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
    
    
    % plot phase distribution
    figure
    desired = input('input desired degree of stimulus phase \n');
    histogram(rad2deg(phase_at_0))
    title('Distribution of Phases on the raw fit signal')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    
    degVec = [0:0.5:360];
    [boot,confBoot,pdf] = density_bootstrap_plot(degVec,rad2deg(phase_at_0));
    title('Distribution of Phases on the raw fit signal for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline(desired)
    
    
    
    figure
    histogram(rad2deg(phase_at_0_acaus))
    title('Distribution of Phases on the acausally filtered fit signal')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    % hilbert phase
    figure
    hilbPhase0conv = hilbPhase0;
    hilbPhase0conv(hilbPhase0<0) = 2*pi + hilbPhase0(hilbPhase0<0);
    histogram(rad2deg(hilbPhase0conv))
    title('Distribution of Hilbert Phase')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
    vline([desired])
    
    
    
end