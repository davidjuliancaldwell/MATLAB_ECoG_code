Z_Constants;

addpath ./scripts;

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('%s_epochs', sid)), 't');    
    load(fullfile(META_DIR, sprintf('lasso-%s', sid)), 'mse', 'se', 'Bs');
    
    t = t(1:10:end);
    rBs = reshape(Bs, [size(Bs, 1), 6, size(Bs,2)/6]);

    % this is the how big of weights version
    freqWeights = sum(abs(rBs), 3);
    figure
%     plot(t, freqWeights);
    plot(t, freqWeights .* repmat(1-mse, [1 6]));
    legend(BAND_NAMES);
    
    allFreqWeights{c} = freqWeights;
    allT{c} = t;
    
%     for d = 1:6
%         subplot(3,2,d);
%         imagesc(squeeze(rBs(:,d,:))');
%         title(BAND_NAMES{d});
%     end
end

%%
L = min(cellfun(@(x) length(x), allFreqWeights));

foo = [];
for c = 1:length(allFreqWeights)
    foo(:, :, c) = allFreqWeights{c}(1:L, :);
end

mu = mean(foo, 3);
sig = sem(foo, 3);


for c = 1:11
    plot(foo(:,5,c));
    hold all;
    pause;
end