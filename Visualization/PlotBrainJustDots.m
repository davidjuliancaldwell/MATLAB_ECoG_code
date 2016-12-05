function PlotBrainJustDots(subjid,chans)

% plots brain, and just the channels of interest 
load(fullfile(getSubjDir(subjid),'trodes.mat'))

PlotCortex(subjid,determineHemisphereOfCoverage(subjid))
% get electrode locations
locs = Grid;
% take labeling from plot dots direc
% plot cortex too
figure
PlotCortex(subjid,'b')
hold on
logicalMat = zeros(size(locs,1),1);
logicalMat(chans) = 1;
logicIndex = logical(logicalMat);
h = scatter3(locs(logicIndex,1),locs(logicIndex,2),locs(logicIndex,3),100,[0,0,0],'filled');

end