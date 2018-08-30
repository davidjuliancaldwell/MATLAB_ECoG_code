function PlotBrainJustDots(subjid,chans,colors,overlay)


if(~exist('colors', 'var') || isempty(colors))
%     colors = [
%         [0 1 0];
%         [0 0 1];
%         [.5 .5 .5];
%         [1 1 0];
%         [1 0.5 0];
%         [0 0.5 1];
%         [1 0 0.5];
%         [1 0.5 0.5];
%         [0.5 1 0.5];
%         [0.5 0.5 1];
%         [1 0 0];
%         
%         ];

colors = [
    0.1059    0.6196    0.4667;
    0.8510    0.3725    0.0078;
    0.4588    0.4392    0.7020;
    0.9059    0.1608    0.5412;
    0.4000    0.6510    0.1176;
    0.9020    0.6706    0.0078;
    0.6510    0.4627    0.1137;
    0.4000    0.4000    0.4000;
    ];

% colors = [
%     0.5529    0.8275    0.7804;
%     1.0000    1.0000    0.7020;
%     0.7451    0.7294    0.8549;
%     0.9843    0.5020    0.4471;
%     0.5020    0.6941    0.8275;
%     0.9922    0.7059    0.3843;
%     0.7020    0.8706    0.4118;
%     0.9882    0.8039    0.8980;
%     ];
end

if (~exist('overlay','var') || isempty(overlay))
    overlay = false;
end


% plots brain, and just the channels of interest
load(fullfile(getSubjDir(subjid),'trodes.mat'))

%PlotCortex(subjid,determineHemisphereOfCoverage(subjid))
% get electrode locations
locs = AllTrodes;
% take labeling from plot dots direc
% plot cortex too
if ~overlay
    figure
    PlotCortex(subjid,'b')
    hold on
else
    gcf;
    hold on
end

for index = 1:length(chans)
    logicalMat = zeros(size(locs,1),1);
    logicalMat(chans{index}) = 1;
    logicIndex = logical(logicalMat);
    h(index) = scatter3(locs(logicIndex,1),locs(logicIndex,2),locs(logicIndex,3),150,colors(index,:),'filled');
    hold on
end

%legend([h(1),h(2)],{'Stimulation electrodes','Recording evoked potentials'})

%legend([h(1),h(2)],{'Non Stimulation electrodes','Map EPs'})


% trodeLabels = [1:gridSize];
% for chan = 1:gridSize
%     txt = num2str(trodeLabels(chan));
%     t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
%     set(t,'clipping','on');
% end

% DJC - 10-18-2017 - for perfect pitch slide
% chans = [22 30];
% logicalMat = zeros(size(locs,1),1);
% logicalMat(chans) = 1;
% logicIndex = logical(logicalMat);
% h = scatter3(locs(logicIndex,1),locs(logicIndex,2),locs(logicIndex,3),100,[1,1,0],'filled');


end