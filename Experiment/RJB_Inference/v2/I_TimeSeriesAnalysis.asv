Z_Constants;

addpath ./scripts;

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, [sid '_epochs.mat']), 'epochs', 't', '*Dur', 'ress', 'tgts', 'bad_channels', 'montage', 'hemi');

    %% regression playground

    dsfac = 10;
    repochs = zeros(size(epochs, 1), size(epochs, 2), size(epochs, 3), ceil(size(epochs, 4)/dsfac));

    for bandi = 1:size(epochs, 1)
        for chani = 1:size(epochs, 3)
            data = squeeze(epochs(bandi, :, chani, :));
            % if normalize
    %         data = zscoreAgainstInterest(data', t<=-preDur, 1)';
            repochs(bandi, :, chani, :) = resample(data', 1, dsfac)';
        end
    end

    %%
    % ok, now, marching through time, we're going to look at the predictive
    % power of each channel / freq / time
    up = double(tgts==1);
    N = 1;
    vals = zeros(N, size(repochs, 3), size(repochs, 4));

    sr2 = zeros(size(repochs, 1), size(repochs, 3), size(repochs, 4));
    conf = zeros(size(repochs, 1));

    for bandi = 1:size(repochs, 1)
        fprintf('bandi: %d\n', bandi);
        for chani = 1:size(repochs, 3)
            fprintf('  chani: %d\n', chani);
            data = squeeze(repochs(bandi, :, chani, :));

            [temp, p] = corr(data, up);
            temp(p > 0.05) = 0;
            sr2(bandi, chani, :) = sign(temp) .* temp.^2;

            for n = 1:N
                vals(n, chani, :) = corr(data, shuffle(up));            
            end        
        end

        conf(bandi) = prctile(max(max(vals.^2, [], 3), [], 2), 95);        

    end

    %% now viz
    figure;
    
    rt = downsample(t, dsfac);
    load recon_colormap

    cval = max(max(max(abs(sr2))));

    for bandi = 1:size(repochs, 1)
        subplot(3,2,bandi);
        temp = squeeze(sr2(bandi, :,:));
%         temp(abs(temp) < conf(bandi)) = 0;

        imagesc(rt, 1:size(repochs, 3), temp);
        vline([-preDur 0 fbDur], 'k');
        colormap(cm);
        set(gca, 'clim', [-cval cval]);
        colorbar;
        title(BAND_NAMES{bandi});
    end
    
    mtit(sid);
    
    fname = sprintf('what_when_where_%s', sid);
    SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
    SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
    
    
    mse = zeros(size(repochs, 4), 1);
    se = zeros(size(repochs, 4), 1);
    
    h = waitbar(0, 'performing lasso regression');
    T = size(repochs, 4);
    
    Bs = [];
    
    for timei = 1:size(repochs, 4)
        waitbar(timei/T, h);
        
        X = repochs(:,:,:,timei);
        X = permute(X, [2 1 3]);
        X = reshape(X, [size(X, 1), size(X,2)*size(X,3)]);
        
        [B, Info] = lasso(X, double(tgts==1)*2-1, 'CV', 10);
        mse(timei) = Info.LambdaMinMSE;
        se(timei) = Info.SE(Info.IndexMinMSE);
        Bs(timei,:) = B(:, Info.IndexMinMSE);        
    end
    
    figure
    plot(rt, mse, 'r', 'linew', 2);
    hold on;
    plot(rt, mse+se, 'r');
    plot(rt, mse-se, 'r');
    
    xlabel('time (s)');
    ylabel('regression MSE');
    
    title(sprintf('10-fold Incremental LASSO regression - %s', sid));

    fname = sprintf('lasso_%s', sid);
    SaveFig(OUTPUT_DIR, fname, 'png', '-r600');
    SaveFig(OUTPUT_DIR, fname, 'eps', '-r600');
    
    save(fullfile(META_DIR, sprintf('lasso-%s', sid)), 'mse', 'se', 'Bs');
    
    mses{c} = mse;
    ses{c} = se;
end

save(fullfile(META_DIR, 'lasso-all'), 'mses', 'ses');