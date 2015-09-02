%%
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
    '7662c2', ...
};


%%

load data/areas.mat;
SMOOTH_TIME_SEC = 0.1;

for sIdx = 11%1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    %% loading data
    fprintf('  loading data: '); tic
%     load(fullfile('data_n', sprintf('%s_epochs.mat', sid)), 'epochs_beta');
    load(fullfile('pmvdata_n150', sprintf('%s_epochs.mat', sid)), 'epochs_beta', 'epochs_hg', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan');
%     load(fullfile('data', sprintf('%s_results.mat', sid)), 'cchan');
    toc;
    
    %% preprocess data
    fprintf('  preprocessing data: '); tic
    c_hg = single(squeeze(epochs_hg(cchan, :, :))');    
    c_hg = GaussianSmooth(c_hg, SMOOTH_TIME_SEC*fs);
    c_hg = c_hg - repmat(mean(c_hg, 1), [size(c_hg, 1), 1]);
    
    c_beta = single(squeeze(epochs_beta(cchan, :, :))');
    c_beta = GaussianSmooth(c_beta, SMOOTH_TIME_SEC*fs);
    c_beta = c_beta - repmat(mean(c_beta, 1), [size(c_beta, 1), 1]);
        
    trs = trodesOfInterest{sIdx};
    trs(trs == cchan) = [];
    
    p_hg_temp = permute(squeeze(epochs_hg(trs, :, :)), [1 3 2]);
    p_hg = single(zeros(size(p_hg_temp)));
    
    for chan = 1:length(trs)
        temp = single(squeeze(p_hg_temp(chan, :, :)));
        temp = GaussianSmooth(temp, SMOOTH_TIME_SEC*fs);
        p_hg(chan, :, :) = temp - repmat(mean(temp, 1), [size(temp, 1), 1]);
    end
    
    save(fullfile('meta', sprintf('%s_extracted.mat', sid)), 'c_hg', 'c_beta', 'p_hg', 'trs', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan');
    toc;    
end