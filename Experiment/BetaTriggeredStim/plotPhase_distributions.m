%% 8-29-2017 - script to plot phase distributions of beta triggered stim signal

%%
close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseOfDelivery';
filePath = promptForBCI2000Recording(baseDir);
load(filePath)

type = input('single or multiple phase of delivery? input "s" or "m"\n','s');

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
    figure
    histogram((f_pos_caus))
    title('Distribution of Frequency of Oscillatory signal for Phase 1')
    ylabel('count')
    xlabel('Frequency in Hz')
        xlim([12 30])

    
    % plot phase distribution
    figure
    desired = input('input desired degree of stimulus phase \n');
    histogram(rad2deg(phase_at_0_pos))
    title('Distribution of Phases on the raw fit signal for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
        vline(desired)

    
    figure
    histogram(rad2deg(phase_at_0_pos_caus))
    title('Distribution of Phases on the causally filtered fit signal for Phase 1')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
        vline([desired])

        
        %%%%%%%%%%%%%%%%
        
    
    % plot frequency stimulus delivery distribution 
    figure
    histogram((f_neg))
    title('Distribution of Frequency of Oscillatory signal for Phase 2')
    ylabel('count')
    xlabel('Frequency in Hz')
    xlim([12 30])
        % plot frequency stimulus delivery distribution 
    figure
    histogram((f_neg_caus))
    title('Distribution of Frequency of Oscillatory signal for Phase 2')
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

    
    figure
    histogram(rad2deg(phase_at_0_neg_caus))
    title('Distribution of Phases on the causally filtered fit signal for Phase 2')
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
    histogram((f_caus))
    title('Distribution of Frequency of Oscillatory signal')
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

    
    figure
    histogram(rad2deg(phase_at_0_caus))
    title('Distribution of Phases on the causally filtered fit signal')
    ylabel('count')
    xlabel('Phase in degrees')
    xlim([0 360])
        vline([desired])

    
end