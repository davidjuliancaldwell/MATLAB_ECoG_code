%% Constants
% modified by DJC 1-10-2016 
clear all;close all;clc
Z_Constants;
addpath ./scripts;

%% parameters

%for idx = 1:length(SIDS) 
    idx = 8;
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
    
    load(fullfile(getSubjDir(subjid), 'trodes.mat'));
    
    clims = [-1 1];
   % w = zeros(size(Grid, 1), 1);
    
  %  w(stims) = -1;
   % w(beta) = 1;
    
    figure
    
%     % original plot
  %  PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 20, 'recon_colormap', 1:size(Grid, 1), true);

%     % to just plot white labels 
    %map = [1 1 0; 0 0 0; 1 0 1];
% PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), [-1 1], 10, map,[],[]);
% colormap('flag')

% DJC - 1-17-2017 - plot brain with white numbers
%map = [1 1 1];
    map = [1 1 1; 1 1 1; 1 1 1];

    w = zeros(size(Grid, 1), 1);
    clims = [-1 1];
PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 15, map, 1:size(Grid, 1), true);

%%

%SaveFig(OUTPUT_DIR, ['coverage-' subjid], 'eps', '-r600');

% stims = [55 56];
% beta = [64];

% stims = [11 12];
% beta = [4];

% stims = [59 60];
% beta = [51];

