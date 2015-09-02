%% analysis looking at power changes in M1/S1 electrodes as a function of
%% distance from control electrode

% common across all remote areas analysis scripts
subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

upvals = [];
upevals = [];
uplvals = [];
uplocs = [];

dnvals = [];
dnevals = [];
dnlvals = [];
dnlocs = [];

dists = [];

for c = 1:length(subjids)
    [~, ~, div] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat']);

    % select only M1/S1 electrodes
    locs = trodeLocsFromMontage(subjids{c}, Montage, true);
    cLoc = locs(controlChannel, :);
    
    [fas, key] = hmatValue(locs);

    keepidxs = ismember(fas, [1:4 9:12]);
    
    interestingTrodes = find(keepidxs);
    locs = locs(keepidxs,:);

    % look for activation
    upmeans = mean(epochZs(:,targetCodes==1),2);
    dnmeans = mean(epochZs(:,targetCodes==2),2);
    
    ct = (1:length(targetCodes))';
    
    upemeans = mean(epochZs(:,targetCodes==1 & ct < div),2);
    dnemeans = mean(epochZs(:,targetCodes==2 & ct < div),2);
    
    uplmeans = mean(epochZs(:,targetCodes==1 & ct >= div),2);
    dnlmeans = mean(epochZs(:,targetCodes==2 & ct >= div),2);
    
    % save the interesting ones
    upvals = cat(1, upvals, upmeans(interestingTrodes));
    upevals = cat(1, upevals, upemeans(interestingTrodes));
    uplvals = cat(1, uplvals, uplmeans(interestingTrodes));
    uplocs = cat(1, uplocs, locs);
    
    dnvals = cat(1, dnvals, dnmeans(interestingTrodes));
    dnevals = cat(1, dnevals, dnemeans(interestingTrodes));
    dnlvals = cat(1, dnlvals, dnlmeans(interestingTrodes));
    dnlocs = cat(1, dnlocs, locs);

    % calculate distances
    mydists = zeros(size(locs,1),1);
    
    for d = 1:size(locs,1)
        temp = [cLoc; locs(d,:)];
        mydists(d) = pdist(temp);
    end
    dists = cat(1, dists, mydists);

end
 
% simple dot plot
figure, plot(dists, upvals, 'r.');
hold on;
plot(dists, dnvals, 'b.');

%% now bin distances

rdists = round(dists/10)*10;

uniqueDistances = unique(rdists);

for c = 1:length(uniqueDistances)
    umu(c) = mean(upvals(rdists == uniqueDistances(c)));
    uer(c) = std(upvals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    uemu(c) = mean(upevals(rdists == uniqueDistances(c)));
    ueer(c) = mean(upevals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    ulmu(c) = mean(uplvals(rdists == uniqueDistances(c)));
    uler(c) = mean(uplvals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    dmu(c) = mean(dnvals(rdists == uniqueDistances(c)));
    der(c) = std(dnvals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    demu(c) = mean(dnevals(rdists == uniqueDistances(c)));
    deer(c) = mean(dnevals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    dlmu(c) = mean(dnlvals(rdists == uniqueDistances(c)));
    dler(c) = mean(dnlvals(rdists == uniqueDistances(c))) / sqrt(sum(rdists == uniqueDistances(c)));
    
    labels{c} = num2str(uniqueDistances(c));
end

jj = jet;
jj = jj(end:-1:1,:);

figure;
h1 = barweb([umu; dmu]', [uer; der]', 1, labels, [], ...
        [], [], jj, [], {'up', 'down'});    
maximize;
set(h1.legend, 'FontSize',24)
set(h1.ax, 'FontSize', 24);
xlabel('dist. from control electrode (mm)', 'FontSize', 24, 'FontName', 'Arial');
ylabel('mean Z score during control', 'FontSize', 24, 'FontName', 'Arial');
title('mean activation as a function of distance (M1/S1/PM)', 'FontSize', 24, 'FontName', 'Arial');

SaveFig(fullfile(pwd, 'figs'), 'dist_overall_all', 'eps');

figure;
h2 = barweb([uemu; demu; ulmu; dlmu]', [ueer; deer; uler; dler]', 1, labels, [], ...
    [], [], jj, [], {'early up', 'early down', 'late up', 'late down'});    
maximize;
set(h2.legend, 'FontSize',24)
set(h2.ax, 'FontSize', 24);
xlabel('dist. from control electrode (mm)', 'FontSize', 24, 'FontName', 'Arial');
ylabel('mean Z score during control', 'FontSize', 24, 'FontName', 'Arial');
title('mean activation as a function of distance (M1/S1/PM)', 'FontSize', 24, 'FontName', 'Arial');
SaveFig(fullfile(pwd, 'figs'), 'dist_prepost_all', 'eps');

% %             
% %     hgsave(fullfile(pwd, 'figs', sprintf('prepostshift.bar.%s.fig',direction)));
%     SaveFig(fullfile(pwd, 'figs'), sprintf('prepostshift.bar.%s',direction), 'eps');
% end
% 
% 
