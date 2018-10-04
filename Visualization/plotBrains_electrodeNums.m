function plotBrains_electrodeNums(subjid,stims,trodeLabels)

if ~exist('trodeLabels','var')
    trodeLabels = 1:size(Grid, 1);
end

load(fullfile(getSubjDir(subjid), 'trodes.mat'));

clims = [-1 1];

figure

map = [.2 1 0; 1 1 1; 1 0 1];
    map = [0.5 0.5 1; 1 1 1; 1 0.5 0.5];

w = zeros(size(Grid, 1), 1);
w(stims(1)) = 1;
w(stims(2)) = -1;
clims = [-1 1];
PlotDotsDirect(subjid, Grid, w, determineHemisphereOfCoverage(subjid), clims, 15, map, trodeLabels, true);

end