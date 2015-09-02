
cd([myGetenv('matlab_devel_dir') '\Experiment\1DBCI']);
outputDir = [myGetenv('output_dir') '\remoteAreas\AllPower\Qual'];

% dsFile = 'ds/26cb98_ud_im_t_ds.mat'; controlChannel = 36; side = 'both'; el = 90; 
% dsFile = 'ds/38e116_ud_mot_h_ds.mat'; controlChannel = 33; side = 'both'; el = 90;
% dsFile = 'ds/4568f4_ud_mot_t_ds.mat'; controlChannel = 56; side = 'both'; el = 90;
% dsFile = 'ds/30052b_ud_im_t_ds.mat'; controlChannel = 29; side = 'r';
% dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; controlChannel = 24; side = 'r';
% dsFile = 'ds/mg_ud_im_t_ds.mat'; controlChannel = 12; side = 'both'; el = 270;
% dsFile = 'ds/04b3d5_ud_im_t_ds.mat'; controlChannel = 45; side = 'l';

% excluding this subject because of experimental probs
% dsFile = 'ds/8381b8_ud_mot_t_ds.mat'; controlChannel = 1; side = 'l';

load(dsFile);
 
sidx = strfind(dsFile, 'ds/') + length('ds/');
eidx = strfind(dsFile, '_');
eidx = eidx(1)-1;

subject = dsFile(sidx:eidx);

cacheFile = [pwd '\AllPower.m.cache\' subject '.mat'];

% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *

epochZs = [];
restZs = [];
targetCodes = [];
resultCodes = [];

badchans = [];

for recnum = 1:length(ds.recs)
    fprintf('processing recording %d of %d\n', recnum, length(ds.recs));

    if(recnum == 1 && strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1) 
        controlChannel = 23;
        warning('little hack here');
    elseif (strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1)
        controlChannel = 24;
    end

    if(strcmp(subject, '26cb98') == 1)
        badchans = union(badchans, 82);
        warning('little hack here');
    end

    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);

    badchans = union(badchans, Montage.BadChannels);

    parameters = CleanBCI2000ParamStruct(parameters);

    signals = double(signals);

    if (size(signals,2) == 64)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
        signals = signals(:, 1:sum(Montage.Montage));
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end

    cRange = getControlRange(parameters);

        fprintf('  Control channel: %i\n', controlChannel);
        fprintf('  Control range: [%f-%f] Hz\n', min(cRange), max(cRange));

    signals = NotchFilter(signals, [60 120 180], parameters.SamplingRate);
    signals = BandPassFilter(signals, [min(cRange) max(cRange)], parameters.SamplingRate, 6);
    signals = abs(hilbert(signals));

    [restStarts, restEnds] = getEpochs(states.TargetCode, 0);
    l = min(length(restStarts),length(restEnds));
    restStarts = restStarts(2:l); % ditch that first rest epoch
    restEnds   = restEnds(2:l);
    clear l;

    [runStarts, runEnds] = getEpochs((states.TargetCode & states.Feedback) ~= 0, 1);
    l = min(length(runStarts),length(runEnds));
    runStarts = runStarts(1:l);
    runEnds   = runEnds(1:l);
    clear l;

    epochSignal = getEpochSignal(signals, runStarts, runEnds);
    restSignal = getEpochSignal(signals, restStarts, restEnds);

    sigavs = squeeze(mean(epochSignal, 1));
    restavs = squeeze(mean(restSignal, 1));
        reststds = squeeze(std(restSignal, 1));

    % My Method, see notes from 2/1/12 in notebook
    epochZ = ((sigavs' - repmat(mean(restavs', 1), size(sigavs', 1), 1)) ./ repmat(std(restavs', 1), size(sigavs', 1), 1))';    
    restZ = ((restavs' - repmat(mean(restavs', 1), size(restavs', 1), 1)) ./ repmat(std(restavs', 1), size(restavs', 1), 1))';    

%     epochZ = (sigavs - repmat(mean(restavs, 2), 1, size(sigavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(sigavs, 2));
%     restZ  = (restavs - repmat(mean(restavs, 2), 1, size(restavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(restavs, 2)); 

    % Tim's Method, see notes from 2/1/12 in notebook
%     epochZ = (sigavs - repmat(mean(restavs, 2), 1, size(sigavs, 2))) ./ repmat(mean(reststds, 2), 1, size(sigavs,2));
%     restZ = zscore(restavs,1,2);
    
    targetCodes = [targetCodes; states.TargetCode(runStarts)];
    resultCodes = [resultCodes; states.ResultCode(runEnds + 1)];
    

    epochZs = [epochZs, epochZ];
    restZs = [restZs, restZ];
end

clearvars -except Montage badchans cRange controlChannel ds dsFile epochZs outputDir restZs resultCodes targetCodes side subject cacheFile
save(cacheFile);

return;

%%

fprintf('  plotting time variant powers: %s\n', subject);

allscores = epochZs';
alltargets = targetCodes;
allresults = resultCodes;

% upscores = allscores(alltargets == up, :);
% downscores = allscores(alltargets == down, :);
% 
% upcontrol = upscores(:, controlChannel);
% downcontrol = downscores(:, controlChannel);
% 
% [h, p] = ttest(upcontrol, 0, 0.05, 'right');
% if (h)
%     fprintf('    up target control activity significantly increased (p = %d)\n', p);
% else
%     fprintf('    up target control activity not significantly increased (p = %d)\n', p);
% end
%     
% [h, p] = ttest(downcontrol, 0, 0.05, 'left');
% if (h)
%     fprintf('    down target control activity significantly deccreased (p = %d)\n', p);
% else
%     fprintf('    down target control activity not significantly deccreased (p = %d)\n', p);
% end
% 
% labelstr = getLabelsFromMontage(Montage, 1:size(allscores, 2));
% labels = [];
% 
% for c = 1:length(labelstr)
%     [~,~,~,d] = regexp(labelstr{c},'[0-9]+');
%     labels(c) = str2num(d{:});
% end; clear d labelstr;
% 
% locs = trodeLocsFromMontage(subject, Montage);
% % 
% 
% [h, p] = ttest(upscores, 0, 0.05/size(allscores,2), 'right');
% h(h == 0) = NaN;
% figure; 
% PlotDotsDirect(subject, locs, h, side, [0 1], 20, 'jet', labels); view(90, 0);
% mtit('up target increases');
% % view(90,0); SaveFig(outputDir, 'upinc90'); view(270,0); SaveFig(outputDir, 'upinc270');
% 
% [h, p] = ttest(downscores, 0, 0.05/size(allscores,2), 'left');
% h(h == 0) = NaN;
% figure; 
% PlotDotsDirect(subject, locs, h, side, [0 1], 20, 'jet', labels);
% mtit('down target decreases');
% % view(90,0); SaveFig(outputDir, 'downdec90'); view(270,0); SaveFig(outputDir, 'downdec270');
% % 
% [h, p] = ttest(allscores, 0, 0.05/size(allscores,2), 'right');
% h(h == 0) = NaN;
% figure; 
% PlotDotsDirect(subject, locs, h, side, [0 1], 20, 'jet', labels);
% mtit('all target increases');
% view(90,0); SaveFig(outputDir, 'allinc90'); view(270,0); SaveFig(outputDir, 'allinc270');

% if(exist('keep.mat','file'))
%     load('keep');
%     keeplocs = cat(1, keeplocs, locs(h == 1,:));
% else
%     keeplocs = locs(h == 1,:);
% end
% save('keep', 'keeplocs'); 
% whos keeplocs
% clear keeplocs;

% 



swin = 15;

up = 1;
down = 2;

dim = ceil(sqrt(size(allscores, 2)));
figure;

labels = getLabelsFromMontage(Montage, 1:size(allscores, 2));


% locate the trial with maximum power difference
upscores = allscores(alltargets == up, controlChannel);
downscores = allscores(alltargets == down, controlChannel);
difference = interpDifference(GaussianSmooth(upscores, swin), alltargets == up, GaussianSmooth(downscores, swin), alltargets == down);
[~, divIdx] = max(difference);

if (strcmp(subject, '26cb98') == 1)
    divIdx = 65;
    warning('BIG hack here');
end

for chan = 1:size(allscores, 2)
    if (sum(badchans == chan) == 0)
        ax(chan) = subplot(dim, dim, chan);

        upscores = allscores(alltargets == up, chan);
        downscores = allscores(alltargets == down, chan);

        upidxs = find(alltargets == up);
        downidxs = find(alltargets == down);

        results = allresults == alltargets;
        upresults = allresults(alltargets == up) == up;
        downresults = allresults(alltargets == down) == down;

    %     figure;
    %     plot(upidxs, upscores, 'r*'); hold on;
        hold on;
    %     plot(downidxs, downscores, 'b*');

        plot(upidxs, GaussianSmooth(upscores, swin), 'r');
        plot(downidxs, GaussianSmooth(downscores, swin), 'b');

    %     plot(find(results == 0), allscores(results == 0, chan), 'ks');

        difference = interpDifference(GaussianSmooth(upscores, swin), alltargets == up, GaussianSmooth(downscores, swin), alltargets == down);
        differences(:, chan) = difference;

        plot(difference, 'k');

        if (chan == controlChannel)
%             [val, differenceIdx] = max(difference);
%             plot(differenceIdx, val, 'gd');

            plot(divIdx, difference(divIdx), 'gd');
        end

        set(gca, 'XTickLabel', {});
        set(gca, 'YTickLabel', {});
        axis tight;
        set(gca, 'ylim', [-5 5]);
        plot([divIdx divIdx], get(gca, 'YLim'), 'g');

        if (chan == controlChannel)
            title(labels{chan}, 'color', 'r');
        else
            title(labels{chan});
        end

        if (chan == size(allscores, 2))
            legend('up','down','difference', 'Location', 'EastOutside');
        end
    else
        differences(:, chan) = 0;
    end
    
end

mtit(sprintf('Time Variant Powers: %s', subject), 'xoff', 0, 'yoff', .03);
maximize(gcf);
%SaveFig(outputDir, sprintf('%s_time_variant', subject));

if(exist('closeFigs', 'var') && closeFigs == true)
    close;
end

%%
% 
% fprintf('  plotting correlations: %s\n', subject);
% 
% upscores = allscores(alltargets == up, :);
% downscores = allscores(alltargets == down, :);
% 
% upcorrs = zeros(size(allscores, 2), 1);
% downcorrs = zeros(size(allscores, 2), 1);
% diffcorrs = zeros(size(allscores, 2), 1);
% 
% for chan = 1:size(allscores, 2)
%     temp = corrcoef(upscores(:,controlChannel), upscores(:,chan));
%     upcorrs(chan) = temp(2,1);
%     temp = corrcoef(downscores(:,controlChannel), downscores(:,chan));
%     downcorrs(chan) = temp(2,1);
%     temp = corrcoef(differences(:,controlChannel), differences(:,chan));
%     diffcorrs(chan) = temp(2,1);
% end
% 
% 
% % ys = 1:size(allscores,2);
% % figure, plot(ys, upcorrs, ys, downcorrs, ys, diffcorrs);
% 
% threshold = 0.2;
% 
% upcorrs(abs(upcorrs) < threshold) = NaN;
% downcorrs(abs(downcorrs) < threshold) = NaN;
% diffcorrs(abs(diffcorrs) < threshold) = NaN;
% 
% upcorrs(badchans) = NaN;
% downcorrs(badchans) = NaN;
% diffcorrs(badchans) = NaN;
% 
% locs = trodeLocsFromMontage(subject, Montage);
% 
% labels = [];
% for num = Montage.Montage
%     labels = [labels 1:num];
% end
% 
% figure;
% % PlotDots(subject, 'all', upcorrs, side, [-1 1], 20, 'jet');
% PlotDotsDirect(subject, locs, upcorrs, side, [-1 1], 20, 'jet', labels);
% if(exist('el','var'))
%     view(el, 0);
% end
% 
% set_colormap_threshold(gcf, [-threshold threshold], [-1 1], [0.8 0.8 0.8]);
% title(sprintf('Correlation with control electrode up target activation, %s, ctl: %d', subject, controlChannel));
% colorbar;
% 
% maximize(gcf);
% %SaveFig(outputDir, sprintf('%s_up_correlation', subject));
% 
% if(exist('closeFigs', 'var') && closeFigs == true)
%     close;
% end
% 
% figure;
% PlotDotsDirect(subject, locs, downcorrs, side, [-1 1], 20, 'jet', labels);
% if(exist('el','var'))
%     view(el, 0);
% end
% 
% set_colormap_threshold(gcf, [-threshold threshold], [-1 1], [0.8 0.8 0.8]);
% title(sprintf('Correlation with control electrode down target activation, %s, ctl: %d', subject, controlChannel));
% colorbar;
% 
% maximize(gcf);
% %SaveFig(outputDir, sprintf('%s_down_correlation', subject));
% 
% if(exist('closeFigs', 'var') && closeFigs == true)
%     close;
% end
% 
% % figure;
% % PlotDotsDirect(subject, locs, diffcorrs, side, [-1 1], 20, 'jet', labels);
% % set_colormap_threshold(gcf, [-threshold threshold], [-1 1], [0.8 0.8 0.8]);
% % title(sprintf('diff corr with control power changes, %s, ctl: %d', subject, controlChannel));
% % colorbar;
% 
% 
% 
% %% look at significant changes between trial quartiles
% % ex '123456' went through 100 trials, divide the trials
% % in groups of 25 and look for significant differences in U,D,Diff* values
% % across groups
% 
% % % define trial groups, this is where we can change this from quartile
% % % division to some other division scheme
% % numgroups = 5;
% % trialGroups = zeros(numgroups,2);
% % trialGroups(:, 1) = ceil(size(allscores, 1)/numgroups);
% % trialGroups(1, 1) = 1;
% % trialGroups(:, 1) = cumsum(trialGroups(:, 1));
% % 
% % trialGroups(1:(end-1), 2) = trialGroups(2:end, 1)-1;
% % trialGroups(end, 2) = size(allscores, 1);
% 
% % changed to use the differenceIndex as the group divider
% numgroups = 2;
% trialGroups = [1 divIdx - 1; divIdx size(allscores, 1)];
% 
% % now do the group by group analysis
% groupupmeans = zeros(size(trialGroups, 1), size(allscores, 2));
% groupupses = zeros(size(trialGroups, 1), size(allscores, 2));
% 
% groupdownmeans = zeros(size(trialGroups, 1), size(allscores, 2));
% groupdownses = zeros(size(trialGroups, 1), size(allscores, 2));
% 
% groupdiffmeans = zeros(size(trialGroups, 1), size(allscores, 2));
% groupdiffses = zeros(size(trialGroups, 1), size(allscores, 2));
% 
% for gnum = 1:size(trialGroups,1)
%     group = trialGroups(gnum, :);
%     
%     subscores = allscores(group(1):group(2), :);
%     subtargets = alltargets(group(1):group(2));
%     subdiffs = differences(group(1):group(2), :);
%     
%     groupupmeans(gnum, :) = mean(subscores(subtargets == up, :), 1);
%     groupupses(gnum, :) = std(subscores(subtargets == up, :), 1) / sqrt(sum(subtargets == up));
%     
%     groupdownmeans(gnum, :) = mean(subscores(subtargets == down, :), 1);
%     groupdownses(gnum, :) = std(subscores(subtargets == down, :), 1) / sqrt(sum(subtargets == down));
%     
%     groupdiffmeans(gnum, :) = mean(subdiffs, 1);
%     groupdiffses(gnum, :) = std(subdiffs, 1) / sqrt(group(2)-group(1));
% end
% 
% % do significance tests
% uppossigs = zeros(size(allscores, 2), 1);
% uppossigsb = zeros(size(allscores, 2), 1);
% upnegsigs = zeros(size(allscores, 2), 1);
% upnegsigsb = zeros(size(allscores, 2), 1);
% 
% downpossigs = zeros(size(allscores, 2), 1);
% downpossigsb = zeros(size(allscores, 2), 1);
% downnegsigs = zeros(size(allscores, 2), 1);
% downnegsigsb = zeros(size(allscores, 2), 1);
% 
% if (numgroups == 2)
%     for chan = 1:size(allscores, 2)
%         prescores = allscores(trialGroups(1, 1):trialGroups(1, 2), chan);
%         postscores = allscores(trialGroups(2, 1):trialGroups(2, 2), chan);
%         pretargets = alltargets(trialGroups(1, 1):trialGroups(1, 2));
%         posttargets = alltargets(trialGroups(2, 1):trialGroups(2, 2));
%     
%         % bonferroni corrected two sample t-test
%         % QUESTION! now that I'm looking at right tailed and left tailed
%         % separately, do I need to do multiple comparisons correction
%         % again? or at least fold that double-comparison in to my original
%         % correction?
%         ptarg = 0.05/size(allscores,2);
%         
%         uppossigs(chan) = ttest2(prescores(pretargets == up), postscores(posttargets == up), ptarg, 'right', 'unequal');
%         uppossigsb(chan) = ttest2(prescores(pretargets == up), postscores(posttargets == up), 0.05, 'right', 'unequal');
%         
%         upnegsigs(chan) = ttest2(prescores(pretargets == up), postscores(posttargets == up), ptarg, 'left', 'unequal');
%         upnegsigsb(chan) = ttest2(prescores(pretargets == up), postscores(posttargets == up), 0.05, 'left', 'unequal'); 
%         
%         downpossigs(chan) = ttest2(prescores(pretargets == down), postscores(posttargets == down), ptarg, 'right', 'unequal');
%         downpossigsb(chan) = ttest2(prescores(pretargets == down), postscores(posttargets == down), 0.05, 'right', 'unequal'); 
%         
%         downnegsigs(chan) = ttest2(prescores(pretargets == down), postscores(posttargets == down), ptarg, 'left', 'unequal');
%         downnegsigsb(chan) = ttest2(prescores(pretargets == down), postscores(posttargets == down), 0.05, 'left', 'unequal'); 
%     end
%     
%     upsigs = uppossigs - upnegsigs;
%     upsigsb = 0.5*uppossigsb - 0.5*upnegsigsb;
%     
%     upsigs(upsigs == 0) = upsigsb(upsigs == 0);
%     
%     downsigs = downpossigs - downnegsigs;
%     downsigsb = 0.5*downpossigsb - 0.5*downnegsigsb;
%     
%     downsigs(downsigs == 0) = downsigsb(downsigs == 0);
%     
%     figure;
%     upsigs(upsigs==0) = NaN;
%     PlotDotsDirect(subject, locs, upsigs, side, [-1 1], 20, 'jet', labels);
%     if(exist('el','var'))
%         view(el, 0);
%     end
%     
%     title(sprintf('change in up target activation after maximal diff (red=dec, blue=inc): %s', subject));
%     
%     maximize(gcf);
%     %SaveFig(outputDir, sprintf('%s_up_sigs', subject));
% 
%     if(exist('closeFigs', 'var') && closeFigs == true)
%         close;
%     end
% 
%     figure;
%     downsigs(downsigs==0) = NaN;
%     PlotDotsDirect(subject, locs, downsigs, side, [-1 1], 20, 'jet', labels);
%     if(exist('el','var'))
%         view(el, 0);
%     end
%     
%     title(sprintf('change in down target activation after maximal diff (red=dec, blue=inc): %s', subject));
% 
%     maximize(gcf);
%     %SaveFig(outputDir, sprintf('%s_down_sigs', subject));
% 
%     if(exist('closeFigs', 'var') && closeFigs == true)
%         close;
%     end
%     
% else
% %     dim = ceil(sqrt(size(allscores, 2)));
% %     figure;
% % 
% %     labels = getLabelsFromMontage(Montage, 1:size(allscores, 2));
% % 
% %     for chan = 1:size(allscores, 2)
% % 
% %         ax(chan) = subplot(dim, dim, chan);
% % 
% %         errorbar(groupupmeans(:,chan), groupupses(:,chan), 'r');
% %         hold on;
% %         errorbar(groupdownmeans(:,chan), groupdownses(:,chan), 'b');
% %         title(labels{chan});
% % 
% %         axis tight;
% %         set(gca, 'YLim', [-3 3]);
% %     end
% % 
% %     legend('up', 'down');
% % 
% %     mtit('Time Variant Powers', 'xoff', 0, 'yoff', .05);
% end