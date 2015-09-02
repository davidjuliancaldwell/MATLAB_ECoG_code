SIDS = {
    '30052b', ...
    '4568f4', ...
    '3745d1', ...
    '26cb98', ...
    'fc9643', ...
    '58411c', ...
    '0dd118', ...
    '7ee6bc', ...
    '38e116', ...
    'f83dbb', ...
};


%%

for sIdx = 1:length(SIDS)
    fprintf('loading data: '); tic;
    load(fullfile('data_p', [SIDS{sIdx} '_packaged.mat'])); toc;
    
    fprintf('extracting broadband...\n');
    for c = 1:length(sigs)
        fprintf('  file %d of %d: ', c, length(sigs)); tic;
        sig = sigs{c};
        fs = pars{c}.SamplingRate.NumericValue;
        
        bb{c} = extractBroadband_FFT(sig, fs, bads);
        toc;
    end
    
    fprintf('saving data: '); tic;
    save(fullfile('data_p', [SIDS{sIdx} '_packaged.mat']), '-append', 'bb'); toc;
    
end