%% DJC  7-13-2016 - script to make fake trodes.mat file from trodes.txt file
% only works for grid right now


%% load bis_trodes.txt using convert function
importTextData


%% make big matrix

matrixElectrodes = [ElectrodeNum x y z];

% sort by electrode number - first 64 in grid

matrixElectrodesSubset = matrixElectrodes(1:64,:);

matrixSorted = sortrows(matrixElectrodesSubset);

%%

save('fakeTrodes.mat','matrixSorted');

