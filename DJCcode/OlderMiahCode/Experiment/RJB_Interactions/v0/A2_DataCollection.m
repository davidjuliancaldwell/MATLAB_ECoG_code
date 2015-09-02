SIDS = {'30052b', 'fc9643'};
SCODES = {'S1', 'S2'};

OUTPUT_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'figures');
META_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'meta');

TouchDir(OUTPUT_DIR);
TouchDir(META_DIR);

PFC_BAS = 46;

%% figure out which electrodes are in the brodman areas of interest

for sIdx = 1:length(SIDS)
    subjid = SIDS{sIdx};
    load(fullfile(META_DIR, sprintf('%s-data.mat', subjid)), 'pfcChannels');
   
    %% extract the data for the pfc electrodes
    subjid = SIDS{sIdx};
    [files, hemi, ~, cChan] = interactionDataFiles(subjid);

    [data, t, fs, tx, targets, results, Montage] = extractBCIEpochs_rjb(files);
    channels = [cChan, pfcChannels];
    isControl = zeros(size(channels)) == 1;
    isControl(1) = 1;
    data = data(:, channels, :);
    
    save(fullfile(META_DIR, sprintf('%s-data.mat', subjid)), 'pfcChannels', 'data', 't', 'fs', 'tx', 'targets', 'results', 'Montage', 'channels', 'isControl');
end
