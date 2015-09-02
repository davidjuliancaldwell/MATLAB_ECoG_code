function [snr_e, snr_l, groupResult, regressionResult] = calculateSNRs(epochs_hg, bad_marker, bad_channels, tgts, t, preDur, fbDur, RESPONSE_TIME)
    et = epochs_hg(:, ~all(bad_marker)' & tgts == 1, :);

    isEarly = false(size(et, 2), 1);
    isEarly(1:floor(size(et, 2)/2)) = true;

    %% here's the withintrial variance-based version
    rest = et(:, :, t <-preDur);
    fb   = et(:, :, t > RESPONSE_TIME & t < fbDur);

%     mu_r = mean(rest, 3);
    mu_r = mean(mean(rest, 3),2);
    
%     temp_r = rest - repmat(mu_r, [1 1 size(rest, 3)]);
    temp_r = rest - repmat(mu_r, [1 size(rest, 2) size(rest, 3)]);
    
%     temp_fb = fb - repmat(mu_r, [1 1 size(fb, 3)]);
    temp_fb = fb - repmat(mu_r, [1 size(fb, 2) size(fb, 3)]);

    
    % the next two lines are wrong
    snr_e = var(reshape(temp_fb(:, isEarly, :), [size(temp_fb, 1) sum(isEarly) * size(temp_fb, 3)]), [], 2) ./ ...
            var(reshape(temp_r(:, isEarly, :),  [size(temp_r,  1) sum(isEarly) * size(temp_r,  3)]), [], 2);
    snr_l = var(reshape(temp_fb(:, ~isEarly, :), [size(temp_fb, 1) sum(~isEarly) * size(temp_fb, 3)]), [], 2) ./ ...
            var(reshape(temp_r(:, ~isEarly, :),  [size(temp_r,  1) sum(~isEarly) * size(temp_r,  3)]), [], 2);
                
%     snr = var(temp_fb, [], 3) ./ var(temp_r, [], 3);
    temp_var = var(reshape(temp_r, size(temp_r, 1), size(temp_r, 2) * size(temp_r, 3)), [], 2);
    snr = var(temp_fb, [], 3) ./ repmat(temp_var, 1, size(temp_fb, 2));
    
    rb = [];
    rstats = [];
   
    figure
    [nx, ny] = subplotDims(size(snr, 1));
    
    for chan = 1:size(snr, 1)
        if (~ismember(chan, bad_channels))
            subaxis(nx, ny, chan, 'Spacing', 0.03, 'padding', 0, 'margin', .05);
            plot(snr(chan,:), 'b.');            
            axis tight
            
%             [rb(chan), rstats(chan)] = corr(snr(chan,:)', (1:size(snr,2))');
            
            [x,~,~,~,g] = regress(snr(chan,:)', [ones(size(snr, 2), 1) (1:size(snr, 2))']);
            rb(chan) = x(2);
            rstats(chan) = g(3);
            
            if (rstats(chan) <= 0.05)            
                set(lsline, 'color', 'k', 'linew', 2)            
            end
        else
            rb(chan) = 0;
            rstats(chan) = 1;
        end       
    end
    maximize;
    
    regressionResult = cat(2, rb', rstats');
    
    [h,p,~,stats] = ttest2(snr(:,isEarly), snr(:, ~isEarly), 'dim', 2);
    groupResult = cat(2, stats.tstat, p);
    
    snr_e(bad_channels) = 0;
    snr_l(bad_channels) = 0;

%     figure
%     plot(snr_e);
%     hold all
%     plot(snr_l);
%     plot(snr_l-snr_e);
%     legend('early', 'late', 'difference');
    
end