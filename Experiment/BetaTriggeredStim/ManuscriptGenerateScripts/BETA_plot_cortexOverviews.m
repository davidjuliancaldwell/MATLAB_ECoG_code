%% DJC - script to plot cortex grids

close all
Z_Constants;
addpath ./scripts;

%% parameters
%SIDS = SIDS(1);

%subjid = SIDS{1};

subjid = input('What is the subjid ? \n ','s');
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
        
    case '0a80cf' % added DJC 5-24-2016
        
        stims = [27 28];
        betaChan = 26;
    case '3f2113' % added DJC 7-23-2015
        stims = [32 31];
        
        betaChan = 40;
        
    otherwise
        error('unknown SID entered');
end

sid = subjid;

if (strcmp(sid,'0b5a2ePlayback'))
    load(fullfile(getSubjDir('0b5a2e'), 'trodes.mat'));
else
    load(fullfile(getSubjDir(subjid),'trodes.mat'))
end

%%

% get electrode locations
locs = Grid;
% take labeling from plot dots direc
% plot cortex too
figure
PlotCortex(subjid,determineHemisphereOfCoverage(subjid))
hold on
% logicalMat = zeros(size(locs,1),1);
% chans = [1:48];
% logicalMat(chans) = 1;
% logicIndex = logical(logicalMat);
%h = scatter3(locs(logicIndex,1),locs(logicIndex,2),locs(logicIndex,3),150,[1,1,1],'filled');

gridSize = length(Grid);

locs = Grid;
markerSize = 15;
trodeLabels = [1:gridSize];
for chan = 1:gridSize
    plot3(locs(chan,1),locs(chan,2),locs(chan,3),'o','MarkerFaceColor',[1 1 1],'MarkerSize',markerSize,'MarkerEdgeColor','k')%i like red (white would be [1 1 1], etc) dots better
    txt = num2str(trodeLabels(chan));
    t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
    set(t,'clipping','on');
end




