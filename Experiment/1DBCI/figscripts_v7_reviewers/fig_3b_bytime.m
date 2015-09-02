%% this script generates all of the bytime figures

fig_setup;

num = 1;

subjid = subjids{num};
id = ids{num};
% clear num;

big = 30;%24;%16;
small = 22;%18;%12;

% % temp used for listing interesting electrodes and their trend
% 
% overallcachefile = fullfile(pwd, 'cache', ['fig_overall.' subjid '.mat']);
% load(overallcachefile, 'usigs', 'dsigs', 'uvals', 'dvals');
% 
% interest = find(usigs | dsigs);
% 
% usigs(uvals < 0) = 0;
% dsigs(dvals < 0) = 0;
% 
% for c = 1:length(interest)
%     fprintf('%d\t%d\n',usigs(interest(c)),dsigs(interest(c)));
% end
% % usigs(interest)
% % dsigs(interest)
% 
% return;
% % end temp

[files, side, div, sessionNumber] = getBCIFilesForSubjid(subjid);

allresults = [];
alltargets = [];
allepochs = [];
allwindows = [];
allsessions = [];
bads = [];

cachefile = fullfile(cacheOutDir, ['fig_bytime.' subjid '.mat']);

if (exist(cachefile, 'file'))
    fprintf('using previously generated cache file for %s\n', subjid);
    load(cachefile);
else
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
        
        if (fs == 2400)
            % cheat and downsample everything
            fprintf('    downsampling from 2.4 KHz\n');
            
            signals = downsample(signals,2);
            states.Feedback = downsample(states.Feedback, 2);
            states.TargetCode = downsample(states.TargetCode, 2);
            states.ResultCode = downsample(states.ResultCode, 2);
            states.Running = downsample(states.Running,2 );
            
            fs = 1200;
        end
        
        % 

        signals = double(signals(:, 1:max(cumsum(Montage.Montage))));
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);

        %

        signalsHilbAmp = hilbAmp(signals, [70 200], parameters.SamplingRate.NumericValue);
        sigHg = log(signalsHilbAmp.^2);

        trialTime = parameters.PreFeedbackDuration.NumericValue + ...
                    parameters.FeedbackDuration.NumericValue + ... 
                    parameters.PostFeedbackDuration.NumericValue;

        if (~exist('prevTrialTime','var'))
            prevTrialTime = trialTime;
        elseif (trialTime ~= prevTrialTime)
            warning('trial time not consistent across runs');
        end

        pre = parameters.PreFeedbackDuration.NumericValue + parameters.ITIDuration.NumericValue;
        post = parameters.FeedbackDuration.NumericValue + parameters.PostFeedbackDuration.NumericValue;
        

        if (~exist('prevfs', 'var'))
            prevfs = fs;
        elseif (prevfs ~= fs)
            error('sampling frequency not consistet across runs');
        end

        presamps  = parameters.PreFeedbackDuration.NumericValue  * fs;
        fbsamps   = parameters.FeedbackDuration.NumericValue     * fs;
        postsamps = parameters.PostFeedbackDuration.NumericValue * fs;

        state = double(states.TargetCode * 8 + states.ResultCode * 2 + states.Feedback);
        state(1) = -1;

        epochs = ones(length(find(diff(state)~= 0)),1);
        epochs(:,1) = cumsum(epochs(:,1));
        newEpochAt = find(diff(state) ~= 0);
        epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];
        epochs(:,4) = states.Feedback(epochs(:,3));
        epochs(:,5) = states.TargetCode(epochs(:,3));
        epochs(:,6) = states.ResultCode(epochs(:,3));

        %% backtrack so that last complete epoch is of result
        lastIdx = find(epochs(:,5) == 0, 1, 'last');

        if (size(epochs, 1) ~= lastIdx)
            fprintf('    trimming epochs (%d) \n', size(epochs, 1)-lastIdx);
            epochs = epochs(1:lastIdx, :);
        end

        allepochs = cat(1, allepochs, epochs);
        
        restsamples = sigHg(states.Feedback == 0, :);

        sigScored = (sigHg - repmat(mean(restsamples,1),size(sigHg,1),1)) ./ repmat(std(restsamples,0,1), size(sigHg,1), 1);
    %     sigScored = lowpass(sigScored, 1, fs, 4);
%         sigScored = GaussianSmooth(sigScored, .5*fs);
    %     sigScored = exp(sigScored);

        fbepochs = find(epochs(:,4)==1);

        windows = getEpochSignal(sigScored, epochs(fbepochs,2)-pre*fs, epochs(fbepochs,2)+post*fs);
        results = epochs(fbepochs+1,5) == epochs(fbepochs+1,6);
        targets = epochs(fbepochs,5);

        allwindows = cat(3, allwindows, windows);
        allresults = cat(1, allresults, results);
        alltargets = cat(1, alltargets, targets);
        allsessions = cat(1, allsessions, ones(size(targets))*sessionNumber(c));
    end
    
    save(cachefile, 'allsessions', 'allresults', 'alltargets', 'allwindows', 'allepochs', 'bads', 'Montage', 'subjid', 'side', 'pre', 'post', 'fs', 'div');
end


clearvars -except allsessions allresults alltargets allwindows allepochs bads Montage subjid side pre post fs div num id theme_colors red blue green big small cacheOutDir figOutDir sessionNumbers;

%% assumes that fig_overall has been run
% fig_overall no longer exists, so we need to do this a different way
% now...
%
% let's try pulling from fig_2b_overall.m

overallcachefile = fullfile(cacheOutDir, ['overall_' subjid '.mat']);
load(overallcachefile, 'uSigs', 'dSigs', 'aSigs');
overallSigs = union(find(aSigs), union(find(uSigs), find(dSigs)));

shiftcachefile = fullfile(cacheOutDir, ['shift_' subjid '.mat']);
load(shiftcachefile);
shiftSigs = union(find(allh), union(find(uph), find(downh)));

% interestingTrodes = union(overallSigs, shiftSigs)';
interestingTrodes = 1:length(allh);
interestingTrodes(bads) = [];


% determine up/down trial number corresponding to div
posttargs = alltargets;
posttargs(1:(div-1)) = 0;

uppostidx = find(posttargs==1, 1, 'first');
downpostidx = find(posttargs==2, 1, 'first');

upcount = cumsum(alltargets==1);
updiv = upcount(uppostidx);

downcount = cumsum(alltargets==2);
downdiv = downcount(downpostidx);

% determine the up/down trial numbers corresponding to session changes
upsessions = allsessions(alltargets==1);
dnsessions = allsessions(alltargets==2);

upsessionchange = find([0; diff(upsessions)]);
dnsessionchange = find([0; diff(dnsessions)]);

t = (-pre*fs:(post*fs-1))/fs;

tallocs = trodeLocsFromMontage(subjid, Montage, true);

if size(interestingTrodes,1) > 1 && size(interestingTrodes,2) == 1
    interestingTrodes = interestingTrodes';
end

warning('int trodes hardcoded');

switch(num)
    case 1
        interestingTrodes = [16 23 18 96];
    case 2
        interestingTrodes = [36 51 42 56];
    case 3
        interestingTrodes = [17 49 10];
    case 4
        interestingTrodes = [39 55 100];
    case 5
        interestingTrodes = [40 56 59 15];
    case 6
        interestingTrodes = [14 12 23];
    case 7
        interestingTrodes = [34 37 46 27];
end
% interestingTrodes = [96];

for trode = interestingTrodes
    fprintf('plotting %s - %s\n', subjid, trodeNameFromMontage(trode, Montage));
    
    figure;
    
    subplot(131); % up mean vs down mean
    muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==1)),2), .5*fs);
    sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==1)),0,2)/sqrt(sum(alltargets==1)), .5*fs);
    plot(t, muSmooth, 'Color', theme_colors(red,:), 'LineWidth', 2);
    hold on;
    plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':', 'LineWidth', 2);
    plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(red,:), 'LineStyle', ':', 'LineWidth', 2);
    
    muSmooth = GaussianSmooth(mean(squeeze(allwindows(:,trode,alltargets==2)),2), .5*fs);
    sigmaSmooth = GaussianSmooth(std(squeeze(allwindows(:,trode,alltargets==2)),0,2)/sqrt(sum(alltargets==2)), .5*fs);
    plot(t, muSmooth, 'Color', theme_colors(blue,:), 'LineWidth', 2);
    hold on;
    plot(t, muSmooth+sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':', 'LineWidth', 2);
    plot(t, muSmooth-sigmaSmooth, 'Color', theme_colors(blue,:), 'LineStyle', ':', 'LineWidth', 2);
    axis tight;
%     legend('up', 'up+SE', 'up-SE', 'down', 'down+SE', 'down-SE');
    plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
    plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
    plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);

    
    set(gca, 'FontSize', small, 'FontName', 'Arial');
    xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
    ylabel('norm. signal power', 'FontSize', big, 'FontName', 'Arial');
    title('average response', 'FontSize', big, 'FontName', 'Arial');

    % prepare to plot the trial by trial HG, smoothed
    gfilt = customgauss([.5*fs+1 7], .125*fs, 3, 0, 0, 1, [0 0]);
    gfilt = gfilt / sum(sum(gfilt));
    [r,c] = size(gfilt);
    rs = ceil(r/2);
    re = floor(r/2);
    cs = ceil(c/2);
    ce = floor(c/2);

    ups = squeeze(allwindows(:,trode,alltargets==1));    
    upsSmooth = conv2(ups,gfilt);    
    upsSmooth = upsSmooth(rs:(end-re),cs:(end-ce));
    downs = squeeze(allwindows(:,trode,alltargets==2));
    downsSmooth = conv2(downs,gfilt);
    downsSmooth = downsSmooth(rs:(end-re),cs:(end-ce));

    clims = [min(min(min(downsSmooth)), min(min(upsSmooth))) max(max(max(downsSmooth)),max(max(upsSmooth)))];

    subplot(132); % evolution of ups
    
    imagesc(t,1:size(ups,2),upsSmooth',clims);
    hold on;
    plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
    plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
    plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    plot(t, updiv*ones(size(t))+.25, 'Color', [.5 .5 .5], 'LineWidth', 3);
    plot(t, updiv*ones(size(t)), 'k', 'LineWidth', 3);
    
    set(gca, 'FontSize', small, 'FontName', 'Arial');
    xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
    ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
    title('up response', 'FontSize', big, 'FontName', 'Arial');
%     title(sprintf('up response (%3.2f, %3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');

    % add in the ticks for session changes
    yticks = get(gca, 'YTick');
    yticklabels = get(gca, 'YTickLabel');
    
    [yticks, idxs] = sort([yticks upsessionchange']);
    newticklabels = cell(length(yticks),1);
    for idx = 1:length(yticks)
        if (idx <= size(yticklabels,1))
            newticklabels(idx) = {yticklabels(idx,:)};
        else
            newticklabels(idx) = {'*'};
        end 
    end
    
    newticklabels = newticklabels(idxs);
    
    set(gca, 'YTick', yticks);
    set(gca, 'YTickLabel', newticklabels);
    set(gca, 'TickDir', 'out');
    
    %
    % next plot!
     
    subplot(133); % evolution of downs
    imagesc(t,1:size(downs,2),downsSmooth',clims);
    hold on;
    plot([0 0], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);    
    plot([post-1 post-1], ylim, 'Color', theme_colors(green,:), 'LineWidth', 4);
    plot([t(15) t(15)], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    plot([-pre+1 -pre+1], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    plot(t, downdiv*ones(size(t))+.25, 'Color', [.5 .5 .5], 'LineWidth', 3);
    plot(t, downdiv*ones(size(t)), 'k', 'LineWidth', 3);
    
    set(gca, 'FontSize', small, 'FontName', 'Arial');
    xlabel('time (s), fb at t=0', 'FontSize', big, 'FontName', 'Arial');
    ylabel('trials', 'FontSize', big, 'FontName', 'Arial');
    title('down response', 'FontSize', big, 'FontName', 'Arial');
%     title(sprintf('down response (%3.2f,%3.2f)', clims(1), clims(2)), 'FontSize', big, 'FontName', 'Arial');
    
    % add in the ticks for session changes
    yticks = get(gca, 'YTick');
    yticklabels = get(gca, 'YTickLabel');
    
    [yticks, idxs] = sort([yticks dnsessionchange']);
    newticklabels = cell(length(yticks),1);
    for idx = 1:length(yticks)
        if (idx <= size(yticklabels,1))
            newticklabels(idx) = {yticklabels(idx,:)};
        else
            newticklabels(idx) = {'*'};
        end 
    end
    
    newticklabels = newticklabels(idxs);
    
    set(gca, 'YTick', yticks);
    set(gca, 'YTickLabel', newticklabels);
    set(gca, 'TickDir', 'out');

    %
    % done with plots!
    
    ba = brodmannAreaForElectrodes(tallocs(trode, :));
    [fa, fkey] = hmatValue(tallocs(trode,:));
    
    tname = trodeNameFromMontage(trode, Montage);
    
% %     use this section for anatomic labeling, useful if you want to know
% %     where all the electrodes are located
%     if (~isnan(ba))
%         if (fa > 0)
%             tit = sprintf('%s-%s (BA: %d, HMAT: %s)', id, tname, ba, fkey{fa});
%         else
%             tit = sprintf('%s-%s (BA: %d)', id, tname, ba);
%         end
%     else
%         if (fa > 0)
%             tit = sprintf('%s-%s (HMAT: %s)', id, tname, fkey{fa});
%         else
%             tit = sprintf('%s-%s', id, tname);
%         end
%     end
%     
%     tit = sprintf('%s, o=%d, s=%d', tit, sum(overallSigs==trode), sum(shiftSigs==trode));
  
% %     otherwise use this section
    tit = sprintf('%s - mean responses', id);
    
    subplot(131); title(tit, 'FontSize', big, 'FontName', 'Arial');
    
%     mtit(tit, 'xoff', 0, 'yoff', .1, 'FontSize', big, 'FontName', 'Arial');
    
    cleantname = strrep(strrep(tname, ')', ''), '(', '');
%     hgsave(fullfile(pwd, 'figs', ['bytime.' subjid '.' cleantname '.fig']));
    
%     SaveFig(fullfile(pwd, 'figs'), ['bytime.' subjid '.' cleantname '.sm']);
%     maximize; 
    set(gcf,'Position',[10 100 1900 700]);

    subplot(131);
    set(gca, 'Units','normalized','Position',[0.10 0.23 0.24 0.6]);
    subplot(132);
    set(gca, 'Units','normalized','Position',[0.39 0.23 0.24 0.6]);
    subplot(133);
    set(gca, 'Units','normalized','Position',[0.72 0.23 0.24 0.6]);    
%     mtit(tit, 'xoff', 0, 'yoff', .03, 'FontSize', big, 'FontName', 'Arial');

    SaveFig(figOutDir, ['bytime.' subjid '.' cleantname '.lg'], 'eps');    
    close all;
%     SaveFig(fullfile(pwd, 'figs'), [subjid '-' tname]);
end

% %% summary for table
% 
% areas = brodmannAreaForElectrodes(tallocs(interestingTrodes, :));
% counter = 1;
% 
% for trode = interestingTrodes'
%     ba = areas(counter);
%     counter = counter + 1;
%     
%     [fa, fkey] = hmatValue(tallocs(trode,:));
%     tname = trodeNameFromMontage(trode, Montage);
%     
%     if (isnan(ba))
%         ba = 0;
%     end
%     
%     if fa == 0
%         fstr = 'none';
%     else
%         fstr = fkey{fa};
%     end
%     
%     tname = trodeNameFromMontage(trode, Montage);    
%     fprintf('%s\t%s\t%s\t%d\t%s\t%3.2f\t%3.2f\t%3.2f\n', ...
%         id, subjid, tname, ba, fstr, tallocs(trode,1), tallocs(trode,2), tallocs(trode,3))
% end
