%% get some data to test

% an excellent choice for test data is 6b68ef's finger twister dataset.
% if you choose different data, make sure to update the periods index
% values below and the gridchannel mapping and grid dimensions below.
[sig, sta, par, fname] = load_bcidatUI;
Montage = loadCorrespondingMontage(fname);

sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, double(sig));

[eStarts, eEnds] = getEpochs(sta.StimulusCode, 1, true);
epochs = getEpochSignal(sig, eStarts, eEnds);

locs = Montage.MontageTrodes;
periods = zeros(size(eEnds));
periods(1:21) = 1;
periods(22:44) = 2;
periods(45:67) = 3;
periods(68:87) = 4;

fs = par.SamplingRate.NumericValue;

nGridRows = 8;
nGridCols = 8;
stimTrodes = [4 5; 4 6]; % row indexed
gridSpacingInMillimeters = 100;
gridChannelMapping = reshape(1:64, 8, 8)';

save('testdata.mat', 'epochs', 'periods', 'locs', 'fs', 'nGridRows', 'nGridCols', 'stimTrodes', 'gridSpacingInMillimeters', 'gridChannelMapping');

clearvars -except epochs periods locs fs nGrid* stimTrodes grid*

%%


