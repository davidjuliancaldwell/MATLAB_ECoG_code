%% Constants
% modified by DJC 1-10-2016
% close all;clear all;clc
Z_Constants;
addpath ./scripts;

%% parameters
SIDS = SIDS(8);

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
    
    
    if (~strcmp(sid,'0b5a2e') && ~strcmp(sid,'0b5a2ePlayback'))
        load(fullfile(getSubjDir(subjid), 'trodes.mat'));
        
    elseif (strcmp(sid,'0b5a2e'))
        % this is for 0b5a2e
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(64, 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
        Grid = locs;
    elseif (strcmp(sid,'0b5a2ePlayback'))
        
        % this is for 0b5a2e
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(64, 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
        Grid = locs;
        
        
    end
    
    
    
    w = zeros(size(Grid, 1), 1);
    
    w(stims) = -1;
    w(beta) = 1;
    
    figure
    PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), [-1 1], 20, 'america', 1:size(Grid, 1), true);
%     SaveFig(OUTPUT_DIR, sprintf(['%sBrain'],sid), 'png', '-r300');
%     SaveFig(OUTPUT_DIR, sprintf(['%sBrain'],sid), 'eps', '-r300');
    
end

% stims = [55 56];
% beta = [64];

% stims = [11 12];
% beta = [4];

% stims = [59 60];
% beta = [51];

