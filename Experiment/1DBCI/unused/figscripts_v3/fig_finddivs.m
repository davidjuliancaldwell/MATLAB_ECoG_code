%% analysis for determining division points in the control electrode
%% by maximizing the separability of the early-late distributions

% common across all remote areas analysis scripts
fig_setup;

for c = 1:length(subjids)
    [~, ~, olddivs(c)] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat']);

    up = 1;
    down = 2;

    ups = epochZs(controlChannel, targetCodes == up);
    dns = epochZs(controlChannel, targetCodes == down);
    
    ups = GaussianSmooth(ups, 10);
    dns = GaussianSmooth(dns, 10);
    
    diffs = interpDifference(ups, targetCodes == up, dns, targetCodes == down);

    figure;
    subplot(211);
    plot(diffs, 'k'); hold on;
    plot(find(targetCodes == up), ups, 'r');
    plot(find(targetCodes == down), dns, 'b');
            
    title(subjids{c});
    
    rsas = zeros(size(diffs));
    
    for d = 1:(length(diffs)-1)
        early = diffs(1:d);
        late = diffs(d+1:end);
        rsas(d) = signedSquaredXCorrValue(late, early);
    end

    rsas(end) = min(rsas(1:(end-1))); % we want to ignore this trivial solution
    
    newdivs(c) = find(max(rsas) == rsas);
    
    [h,p] = ttest2(diffs((newdivs(c)+1):end), diffs(1:newdivs(c)));
    if (h)
        fprintf('%s: ttest passed (p=%f)\n', subjids{c},p);
        p
    else
        fprintf('%s: ttest failed (p=%f)\n', subjids{c},p);
    end
    
    subplot(212);
    plot(rsas);

    if (c == 4)
        figure;
        plot(rsas,'k.');
        hold on;axis tight;
        loc = find(max(rsas) == rsas);
        plot(loc, rsas(loc), 'o', 'MarkerSize', 10, 'Color', 'k');
        axis off;
        
        ylimc = ylim;
        ylim([-0 ylimc(2)]);
        plot(xlim, [0  0 ], 'Color', theme_colors(green,:), 'LineWidth', 8);
        plot(xlim, [.2 .2], 'Color', theme_colors(green,:), 'LineWidth', 1);
        plot(xlim, [.4 .4], 'Color', theme_colors(green,:), 'LineWidth', 1);
        plot(xlim, [.6 .6], 'Color', theme_colors(green,:), 'LineWidth', 1);
        plot(xlim, [.8 .8], 'Color', theme_colors(green,:), 'LineWidth', 1);
        plot(rsas,'k.');
        
%         SaveFig(figOutDir, 'find_div_ex', 'eps');
    end
end

% this is a comparison of the old division values to the new division
% values.
[olddivs; newdivs]

fprintf('to use these values with other scripts, update getBCIFilesForSubjid.m\n');