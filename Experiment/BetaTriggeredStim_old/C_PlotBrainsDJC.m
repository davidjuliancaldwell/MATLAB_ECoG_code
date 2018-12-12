%% Constants
% modified by DJC 1-10-2016
% cd c:\users\david\desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim
% close all;clear all;clc
close all
Z_Constants;
addpath ./scripts;

%% parameters
SIDS = SIDS(7);
%%
for idx = 1:length(SIDS)
    subjid = SIDS{idx};
    switch(subjid)
        case '8adc5c'
            stims = [31 32];
            beta = 8;
        case 'd5cd55'
            stims = [54 62];
            beta = 53;
        case 'c91479'
            stims = [55 56];
            beta = 64;
        case '7dbdec'
            stims = [11 12];
            beta = 4;
        case '9ab7ab'
            stims = [59 60];
            beta = 51;
        case '702d24'
            stims = [13 14];
            beta = 5;
        case 'ecb43e'
            stims = [56 64];
            beta = 55;
        case '0b5a2e'
            stims = [22 30];
            beta = 31;
        case '0b5a2ePlayback'
            stims = [22 30];
            beta = 31;
        otherwise
            error('unknown SID entered');
    end
    
    sid = subjid;
    
    load(strcat(subjid,'epSTATSsig.mat'))
    
    if (strcmp(sid,'0b5a2ePlayback'))
        load(fullfile(getSubjDir('0b5a2e'), 'trodes.mat'));
    else
        load(fullfile(getSubjDir(subjid),'trodes.mat'))
    end

    
    
    %%
    close all
    
    %% plotting average deflection
    w = nan(size(Grid, 1), 1);
    for i = 1:64
        if (i~=stims)
            w(i) = min(sigChans{i}{1}{3});
        end
    end
    
    % DJC -10-18-2017 - do this to do different colors of just dots 
        w = zeros(size(Grid,1),1);
        w(stims) = -1;
        w(beta) = 0;
    
    
    if strcmp(subjid,'c91479')
        w(1) = NaN;
    end
    
    if strcmp(subjid,'7dbdec')
        w(57) = NaN;
    end
    
        clims = [min(w) max(w)];

        
    figure
    PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, 'recon_colormap', 1:size(Grid, 1), true);
    
    % very often, after plotting the brain and dots, I add a colorbar for
    % reference as to what the dot colors mean
    load('recon_colormap'); % needs to be the same as what was used in the function call above
    colormap(cm);
    h = colorbar;
        ylabel(h,'Volts (\muV)')
   title({sid 'Median CCEP Magnitude ','Aggregated for all Conditions','10-30 ms post Stimulus'})
    set(gca,'fontsize', 14)
%     %     PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), [-1 1], 20, 'america', 1:size(Grid, 1), true);
%     %     SaveFig(OUTPUT_DIR, sprintf(['%sBrain'],sid), 'png', '-r300');
%     %     SaveFig(OUTPUT_DIR, sprintf(['%sBrain'],sid), 'eps', '-r300');
%     
%     w = nan(size(Grid,1),1);
%     for i = 1:64
%         if (i~=stims)
%             w(i) = min(sigChans{i}{1}(:,1));
%         end
%     end
%     
%         clims = [min(w) max(w)];
% 
%     
%         figure
%     PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, 'recon_colormap', 1:size(Grid, 1), true);
%     
%     % very often, after plotting the brain and dots, I add a colorbar for
%     % reference as to what the dot colors mean
%     load('recon_colormap'); % needs to be the same as what was used in the function call above
%     colormap(cm);
%     h = colorbar;
%     title({sid 'Baseline and Test Pulse CCEP difference','10-30 ms post Stimulus'})
%     ylabel(h,'Volts (\muV)')
%     set(gca,'fontsize', 14)
%     
%     %% z-scores
%     w = nan(size(Grid, 1), 1);
%     for i = 1:64
%         if (i~=stims)
%             for j = 1:length(sigChans{i})-1 
%             w(i) = min(sigChans{i}{3});
%             end
%         end
%     end
%     
%     
   %% z score difference 
    
    w = nan(size(Grid, 1), 1);
    for i = 1:64
        if (i~=stims)
            
           w(i) = CCEPbyNumStim{i}{1}{3}{1};
        end
    end
    
        clims = [min(w) max(w)];

    
        figure
    PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, 'recon_colormap', 1:size(Grid, 1), true);
    
    % very often, after plotting the brain and dots, I add a colorbar for
    % reference as to what the dot colors mean
    load('recon_colormap'); % needs to be the same as what was used in the function call above
    colormap(cm);
    h = colorbar;
    title({sid 'Z-score for > 5 stims','10-30 ms post Stimulus'})
    ylabel(h,'Z-score')
    set(gca,'fontsize', 14)
    
    %% plot differences
    
        w = nan(size(Grid,1),1);
    for i = 1:64
        if (i~=stims & CCEPbyNumStim{i}{1}{3}{1} > 5 )
            w(i) = 100*(CCEPbyNumStim{i}{1}{3}{2} - CCEPbyNumStim{i}{1}{3}{5})/CCEPbyNumStim{i}{1}{3}{5};
        end
    end
    
    clims = [min(w) max(w)];

    
        figure
    PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, 'recon_colormap', 1:size(Grid, 1), true);
    
    % very often, after plotting the brain and dots, I add a colorbar for
    % reference as to what the dot colors mean
    load('recon_colormap'); % needs to be the same as what was used in the function call above
    colormap(cm);
    h = colorbar;
    title({sid 'Percent Baseline and Test Pulse (>5 stims) CCEP difference','10-30 ms post Stimulus','z-score greater than 5'})
    ylabel(h,'Percent Difference')
    set(gca,'fontsize', 14)
    
end
    
%%

% stims = [55 56];
% beta = [64];

% stims = [11 12];
% beta = [4];

% stims = [59 60];
% beta = [51];

