subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
ids = {'S1','S2','S3','S4','S5','S6','S7'};
num = 4;

subjid = subjids{num};
id = ids{num};

tcs;

[files, side, div] = getBCIFilesForSubjid(subjid);

bads = [];
alltargets = [];
allwindows = [];
allfbscores = [];

fprintf('running analysis for %s\n', subjid);

for c = 1:length(files)
    fprintf('  processing file %d\n', c);

    file = files{c};
    [signals, states, parameters] = load_bcidat(file);
    load(strrep(file, '.dat', '_montage.mat'));
    subjid = extractSubjid(file);

    bads = union(bads, Montage.BadChannels);
    control = parameters.TransmitChList.NumericValue;
    fs = parameters.SamplingRate.NumericValue;

    signals = double(signals(:, 1:max(cumsum(Montage.Montage))));

    signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    signals = signals(:,40);

    signalsHilbAmp = hilbAmp(signals, [70 200], parameters.SamplingRate.NumericValue);
    sigHg = log(signalsHilbAmp.^2);
    
    [starts, ~] = getEpochs(states.Feedback, 1);

    % get the time variant data
%     sigScored = zscore(sigHg,0,1);    
%     sigScored = sigHg;
    restSig = sigHg(states.TargetCode == 0);
    sigScored = (sigHg-mean(restSig)) / std(restSig);
    
    windows = getEpochSignal(sigScored, starts - 3*fs, starts+parameters.FeedbackDuration.NumericValue*fs);

    allwindows = cat(3, allwindows, windows);
    alltargets = cat(1, alltargets, states.TargetCode(starts));
    
    % get the epoch averages
    fbvals = mean(squeeze(getEpochSignal(sigScored, starts, starts+parameters.FeedbackDuration.NumericValue*fs)))';
    restvals = mean(squeeze(getEpochSignal(sigHg, starts-3*fs, starts-2*fs)))';
    
%     fbscores = (fbvals-mean(restvals))/std(restvals);
    fbscores = fbvals;
    allfbscores = cat(1, allfbscores, fbscores);
end

%%

windows = squeeze(allwindows);
subplot(211);
imagesc(windows');

subplot(212);
swin = GaussianSmooth2(windows, [round(size(windows,1)/10) round(size(windows,2)/10)], [round(size(windows,1)/20) round(size(windows,2)/20)]);
% swin = GaussianSmooth2(windows-repmat(mean(mean(windows)),size(windows,1),size(windows,2)), [round(size(windows,1)/10) round(size(windows,2)/10)], [round(size(windows,1)/20) round(size(windows,2)/20)]);
imagesc(swin');

fbmeans = mean(windows(3000:end,:));
[h,p] = ttest2(fbmeans(1:50), fbmeans(50:end))
[h2,p2] = ttest2(allfbscores(1:50), allfbscores(50:end))
figure, plot(1:108, fbmeans, 1:108, allfbscores)

% %% this new method only looks at electrodes showing a significant change
% %% over the course of all trials.  It assumes that fig_prepostshift has
% %% been run
% 
% load(fullfile(myGetenv('output_dir'), '1DBCI', 'cache', ['fig_prepost.' subjid '.mat']), 'allh', 'uph', 'downh');
% % interestingTrodes = union(union(find(allh), find(uph)), find(downh));
% interestingTrodes = find(allh);
% 
% badIdxs = ismember(interestingTrodes, bads);
% interestingTrodes(badIdxs) = [];
% 
% % % %% assumes that fig_overall has been run
% % % 
% % overallcachefile = fullfile(myGetenv('output_dir'), '1DBCI', 'cache', ['fig_overall.' subjid '.mat']);
% % load(overallcachefile, 'usigs', 'dsigs');
% % 
% % interestingTrodes = union(find(usigs), find(dsigs));
% 
% % determine up/down trial number corresponding to div
% posttargs = alltargets;
% posttargs(1:(div-1)) = 0;
% 
% uppostidx = find(posttargs==1, 1, 'first');
% downpostidx = find(posttargs==2, 1, 'first');
% 
% upcount = cumsum(alltargets==1);
% updiv = upcount(uppostidx);
% 
% downcount = cumsum(alltargets==2);
% downdiv = downcount(downpostidx);
% 
% t = (-pre*fs:(post*fs-1))/fs;
% 
% tallocs = trodeLocsFromMontage(subjid, Montage, true);
% 
% for trode = interestingTrodes
%     fprintf('plotting %s - %s\n', subjid, trodeNameFromMontage(trode, Montage));
%     
%     figure;
%     
%     subplot(131); % up mean vs down mean
%     muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==1)),2), .5*fs);
%     sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==1)),0,2)/sqrt(sum(alltargets==1)), .5*fs);
%     plot(t, muSmooth, 'Color', theme_colors(red,:), 'LineWidth', 2);
%     hold on;
%     plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':');
%     plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':');
%     
%     muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==2)),2), .5*fs);
%     sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==2)),0,2)/sqrt(sum(alltargets==2)), .5*fs);
%     plot(t, muSmooth, 'Color', theme_colors(blue,:), 'LineWidth', 2);
%     hold on;
%     plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':');
%     plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':');
%     axis tight;
% %     legend('up', 'up+SE', 'up-SE', 'down', 'down+SE', 'down-SE');
%     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
%     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
%     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
%     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
% 
%     
%     set(gca, 'FontSize', small, 'FontName', 'Arial');
%     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
%     ylabel('z(HG power)', 'FontSize', big, 'FontName', 'Arial');
%     title('average response', 'FontSize', big, 'FontName', 'Arial');
% 
%     % prepare to plot the trial by trial HG, smoothed
%     gfilt = customgauss([.5*fs+1 7], .125*fs, 3, 0, 0, 1, [0 0]);
%     gfilt = gfilt / sum(sum(gfilt));
%     [r,c] = size(gfilt);
%     rs = ceil(r/2);
%     re = floor(r/2);
%     cs = ceil(c/2);
%     ce = floor(c/2);
% 
%     ups = squeeze(allwindows(:,trode,alltargets==1));    
%     upsSmooth = conv2(ups,gfilt);    
%     upsSmooth = upsSmooth(rs:(end-re),cs:(end-ce));
%     downs = squeeze(allwindows(:,trode,alltargets==2));
%     downsSmooth = conv2(downs,gfilt);
%     downsSmooth = downsSmooth(rs:(end-re),cs:(end-ce));
% 
%     clims = [min(min(min(downsSmooth)), min(min(upsSmooth))) max(max(max(downsSmooth)),max(max(upsSmooth)))];
% 
%     subplot(132); % evolution of ups
%     
%     imagesc(t,1:size(ups,2),upsSmooth',clims);
%     hold on;
%     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
%     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
%     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
%     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
%     plot(t, updiv*ones(size(t)), 'k', 'LineWidth', 2);
%     
%     set(gca, 'FontSize', small, 'FontName', 'Arial');
%     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
%     ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
%     title(sprintf('up HG response by trial (%3.2f, %3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');
% 
%     subplot(133); % evolution of downs
%     imagesc(t,1:size(downs,2),downsSmooth',clims);
%     hold on;
%     plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
%     plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
%     plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
%     plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
%     plot(t, downdiv*ones(size(t)), 'k', 'LineWidth', 2);
%     
%     set(gca, 'FontSize', small, 'FontName', 'Arial');
%     xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
%     ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
%     title(sprintf('down HG response by trial (%3.2f,%3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');
%     
% %     ba = brodmannAreaForElectrodes(tallocs(trode, :));
% %     [fa, fkey] = hmatValue(tallocs(trode,:));
% %     
%     tname = trodeNameFromMontage(trode, Montage);
% %     
% %     if (~isnan(ba))
% %         if (fa > 0)
% %             tit = sprintf('%s-%s (BA: %d, HMAT: %s)', id, tname, ba, fkey{fa});
% %         else
% %             tit = sprintf('%s-%s (BA: %d)', id, tname, ba);
% %         end
% %     else
% %         if (fa > 0)
% %             tit = sprintf('%s-%s (HMAT: %s)', id, tname, fkey{fa});
% %         else
%             tit = sprintf('%s-%s', id, tname);
% %         end
% %     end
%     
%     subplot(131); title(tit);
%     
% %     mtit(tit, 'xoff', 0, 'yoff', .1, 'FontSize', big, 'FontName', 'Arial');
%     
%     cleantname = strrep(strrep(tname, ')', ''), '(', '');
% %     hgsave(fullfile(pwd, 'figs', ['bytime.' subjid '.' cleantname '.fig']));
%     
% %     SaveFig(fullfile(pwd, 'figs'), ['bytime.' subjid '.' cleantname '.sm']);
% %     maximize; 
%     set(gcf,'Position',[10 100 1900 400]);
%     
% %     mtit(tit, 'xoff', 0, 'yoff', .03, 'FontSize', big, 'FontName', 'Arial');
%     SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), ['bytime.' subjid '.' cleantname '.lg'], 'eps');    
%     
% %     SaveFig(fullfile(pwd, 'figs'), [subjid '-' tname]);
% end
% 
% % %% summary for table
% % 
% % areas = brodmannAreaForElectrodes(tallocs(interestingTrodes, :));
% % counter = 1;
% % 
% % for trode = interestingTrodes'
% %     ba = areas(counter);
% %     counter = counter + 1;
% %     
% %     [fa, fkey] = hmatValue(tallocs(trode,:));
% %     tname = trodeNameFromMontage(trode, Montage);
% %     
% %     if (isnan(ba))
% %         ba = 0;
% %     end
% %     
% %     if fa == 0
% %         fstr = 'none';
% %     else
% %         fstr = fkey{fa};
% %     end
% %     
% %     tname = trodeNameFromMontage(trode, Montage);    
% %     fprintf('%s\t%s\t%s\t%d\t%s\t%3.2f\t%3.2f\t%3.2f\n', ...
% %         id, subjid, tname, ba, fstr, tallocs(trode,1), tallocs(trode,2), tallocs(trode,3))
% % end
