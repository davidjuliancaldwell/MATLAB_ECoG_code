load('d:\research\subjects\d74850\other\bcifiles.mat');

bads = [];
targets = [];
results = [];
windows = [];
errors = [];

for c = 1:length(newlist)
    fprintf('working on file (%d of %d): %s\n', c, length(newlist), newlist{c});
    
    [sig, sta, par] = load_bcidat(newlist{c});
    load(strrep(newlist{c}, '.dat', '_montage.mat'));
    fs = par.SamplingRate.NumericValue;
    sig = sig(:,1:max(cumsum(Montage.Montage)));
    
    sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));
    bads = union(bads, Montage.BadChannels);
    
    hg = log(hilbAmp(sig, [70 200], fs).^2);
    
    restSamps = hg(sta.TargetCode == 0, :);
    
    z = bsxfun(@minus, hg, mean(restSamps, 1));
    z = bsxfun(@rdivide, z, std(restSamps, 1));
    
    
    [starts, stops] = getEpochs(sta.Feedback, 1, true);
    preSamps = (par.ITIDuration.NumericValue + par.PreFeedbackDuration.NumericValue)*fs;
    postSamps = par.PostFeedbackDuration.NumericValue*fs;
    
    [~, ~, ise] = deriveISE(sta, par); % get the trial-by-trial ISE
    
    while stops(end)+postSamps > length(sig)
        stops(end) = [];
        starts(end) = [];
        ise(end) = [];
    end
    
    targets = cat(1, targets, sta.TargetCode(stops));
    results = cat(1, results, sta.ResultCode(stops));    
    errors  = cat(1, errors, ise);
    
    wins = getEpochSignal(z, starts-preSamps, stops+postSamps);
    % HACK!
    wins = wins(1:8440,:,:);
    % END HACK
    windows = cat(3, windows, wins);
    
end

%% plot overall activations

for c = 6% 49:size(windows,2)%48%25:48%1:10%size(windows,2)
    figure;
    
    channelData = squeeze(windows(:,c,:));
    
    ups = targets == 1;
    upData = channelData(:,ups);
    
    downs = targets == 2;
    downData = channelData(:,downs);
    
    t = ((1-preSamps):(size(windows,1)-preSamps))/fs;
    
    subplot(311);
    plotWSE(t,upData, 'r', .5, 'r-');
    hold on;
    plotWSE(t,downData, 'b', .5, 'b-');
    title(sprintf('mean HG response %s', trodeNameFromMontage(c, Montage)));
    ylabel('zscore');
    xlabel('time(s)');
    legend('','up SE','up mean','','down SE','down mean');
    
    subplot(312);
    tData = upData';
    sData = GaussianSmooth2(tData, [12 90], [4 30]);
    imagesc(t, 1:size(sData,1), sData);
    title('up trials');
    ylabel('trial');
    xlabel('time(s)');
    
    

    subplot(313);
    tData = downData';
    sData = GaussianSmooth2(tData, [12 90], [4 30]);
    imagesc(t, 1:size(sData,1), sData);
    title('down trials');
    ylabel('trial');
    xlabel('time(s)');
    
end

