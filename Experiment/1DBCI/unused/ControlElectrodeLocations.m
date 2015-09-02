%% analysis showing control electrode locations on the talairach brain

% common across all remote areas analysis scripts
subjects = {
    '04b3d5'
    '26cb98'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };



controlLocs = [];

for c = 1:length(subjects)
    load(['AllPower.m.cache\' subjects{c} '.mat']);

    % do stuff
    load([getSubjDir(subjects{c}) 'tail_trodes.mat']);
    controlLocs = cat(1, controlLocs, Grid(controlChannel,:));
    
    clearvars -except c subjects controlLocs;
end

figure;
subplot(211);
PlotDotsDirect('tail', controlLocs, ones(size(controlLocs,1),1),'both',[0 1],10,'jet',[],false);
view(90, 0);
subplot(212);
PlotDotsDirect('tail', controlLocs, ones(size(controlLocs,1),1),'both',[0 1],10,'jet',[],false);
view(270, 0);
mtit('Control Electrode Locations');


