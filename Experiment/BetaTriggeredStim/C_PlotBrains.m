%% Constants
% modified by DJC 1-10-2016 
Z_Constants;
addpath ./scripts;

%% parameters
SIDS = SIDS(6);

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
        otherwise
            error('unknown SID entered');            
    end
    
    load(fullfile(getSubjDir(subjid), 'trodes.mat'));
    
    
    w = zeros(size(Grid, 1), 1);
    
    w(stims) = -1;
    w(beta) = 1;
    
    figure
    PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), [-1 1], 20, 'america', 1:size(Grid, 1), true);
%     SaveFig(OUTPUT_DIR, ['coverage-' subjid], 'png', '-r300');
end

% stims = [55 56];
% beta = [64];

% stims = [11 12];
% beta = [4];

% stims = [59 60];
% beta = [51];

