%% load the data
load testdata.mat % should be epochs, periods, fs, nGridRows, nGridCols, stimTrodes, gridSpacingInMillimeters, gridChannelMapping


%% restingStimAnalysis
[spectra, hz, avSpectra, avSpectraSem, sortedPeriods] = restingStimAnalysis(epochs, periods, fs, 'fft'); % method could also be 'pwelch'

% calculate the distance of each grid electrode from the stimulus trodes,
% here, we're treating the two electrodes as equal, which may not be the
% case in human stim, where the stimuli were not symmetrically balanced,
% thus creating a difference between the anode and the cathode.
distances = trodeDistance(nGridRows, nGridCols, stimTrodes, gridSpacingInMillimeters);

% let's bin the distances by integer multiples of the gridSpacing
tempDistanceIndices = floor(distances/gridSpacingInMillimeters) + 1;
distanceValues = (0:1:max(max(tempDistanceIndices-1)))*gridSpacingInMillimeters;

% and vectorize these to be common with the channel index format of the
% data
distanceIndices = zeros(size(spectra, 2), 1);
for x = 1:nGridRows
    for y = 1:nGridCols
        distanceIndices(gridChannelMapping(x, y)) = tempDistanceIndices(x, y);
    end
end

%% plotting Functions
channelsOfInterest = randi(size(epochs, 2), [8, 1]);
channelsOfInterest(5:end) = [];

figureTitles = cell(size(channelsOfInterest));
for c = 1:length(figureTitles)
    figureTitles{c} = sprintf('channel %d', channelsOfInterest(c));
end

% plots a 2-d image showing all of the spectra for a given channel, divided
% by vertical lines that represent the 'period changes' (e.g. pre-stim,
% post-stim, post-30, post-60.  The spectra are normalized by the spectra
% from a given period
handles{1} = plotTimeVariantSpectra(spectra(:, channelsOfInterest, :), hz, periods, periods(1), figureTitles);

% plots the average spectra from each of the periods listed above for a
% given channel, with the SEM.
handles{2} = plotAverageSpectra(avSpectra(:, channelsOfInterest, :), avSpectraSem(:, channelsOfInterest, :), hz, sortedPeriods, figureTitles);

% plots a bar plot of the power within a given electrode(s) / band(s) combination
handles{3} = plotBandBar(spectra(:, channelsOfInterest, :), hz, [4 8; 12 18; 70 200], {'alpha', 'beta', 'hg'}, periods, sortedPeriods, figureTitles);

% plots a line-error plot of power in one or more bands (for all
% electrodes), as a function of distance
handles{4} = plotBandByDistance(spectra, hz, [4 8; 12 18; 70 200], {'Alpha', 'Beta', 'High-gamma'}, distanceIndices, distanceValues, periods, sortedPeriods);

