%% this is an analysis script that is run by the corresponding batch
%% script.  It generates the 

% subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
% subjid = subjids{3};

% subjid = 'd74850';

[files, side] = getBCIFilesForSubjid(subjid);

allmeans = [];
allepochs = [];
bads = [];

cachefile = fullfile(myGetenv('output_dir'), '1DBCI', 'cache', ['fig_overall.' subjid '.mat']);

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
        % 
        
        fs = parameters.SamplingRate.NumericValue;
        signals = double(signals(:, 1:max(cumsum(Montage.Montage))));
        
        if (fs == 1200 || fs == 2400)
            signals = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, signals);
        else
            signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
        end
 
        %

%         warning ('changed the filter settings.  click to acknowledge'); pause;
        
%         signalsHilbAmp = hilbAmp(signals, [77.5 97.5], parameters.SamplingRate.NumericValue);
        signalsHilbAmp = hilbAmp(signals, [70 200], parameters.SamplingRate.NumericValue);
        sigHg = log(signalsHilbAmp.^2);
%         sigHg = signalsHilbAmp;

        restSig = sigHg(states.TargetCode==0,:);
        sigScored = (sigHg - repmat(mean(restSig,1),size(sigHg,1),1)) ./ repmat(std(restSig),size(sigHg,1),1);
        %

        % should only affect dftask
        states.ResultCode(states.Feedback == 1) = 0;
        % end should only
        
        state = double(states.TargetCode * 8 + states.ResultCode * 2 + states.Feedback);
        state(1) = -1;

        epochs = ones(length(find(diff(state)~= 0)),1);
        epochs(:,1) = cumsum(epochs(:,1));
        newEpochAt = find(diff(state) ~= 0);
        epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];

        epochs(:,4) = states.Feedback(epochs(:,3));
        epochs(:,5) = states.TargetCode(epochs(:,3));
        epochs(:,6) = states.ResultCode(epochs(:,3));

        % backtrack so that last full epoch is of result
        %  in this check we look for the last target code to be zero (which is
        %  indicative of a rest epoch).  This epoch may or may not be complete,
        %  but would imply that that the last complete epoch was the one before
        %  it, a result epoch
        lastIdx = find(epochs(:,5) == 0, 1, 'last');

        if (size(epochs, 1) ~= lastIdx)
            fprintf('  trimming epochs (%d) \n', size(epochs, 1)-lastIdx);
            epochs = epochs(1:lastIdx, :);
        end

        allepochs = cat(1, allepochs, epochs);

        means = zeros(size(epochs,1),size(signals,2));

        for c = 1:size(epochs,1)
            data = sigScored(epochs(c,2):epochs(c,3),:);
            means(c,:) = mean(data, 1); 
        end

%         rests = means(epochs(:,5)==0,:);
%         rmeans = mean(rests,1);
%         rstd = std(rests, 0, 1);
%         means = (means - repmat(rmeans, size(means,1), 1)) ./ repmat(rstd, size(means, 1), 1);

        allmeans = cat(1, allmeans, means);
    end
    
    save(cachefile, 'allmeans', 'allepochs', 'bads', 'Montage', 'subjid', 'side');
end
%% The Simple Version
% determine average z-score by epoch type
% determine significance (~= zero) for each
% plot the average z-score by epoch type on the brain, thresholded by sig

allmeans(:,bads) = 0;

ptarg = 0.05/size(allmeans,2);

restIdxs = find(allepochs(:,5) == 0);
fbIdxs   = find(allepochs(:,4) == 1);
targets = allepochs(fbIdxs,5);

restMeans = allmeans(restIdxs, :);
fbMeans   = allmeans(fbIdxs,  :);

up = 1;
down = 2;

avals = mean(fbMeans, 1);
[asigs, aps] = ttest2(fbMeans, restMeans, ptarg, 'right', 'unequal');
asigs(isnan(asigs)) = 0;

uvals = mean(fbMeans(targets == up, :),1);
[usigs, ups] = ttest2(fbMeans(targets == up, :), restMeans, ptarg, 'right', 'unequal');
usigs(isnan(usigs)) = 0;

dvals = mean(fbMeans(targets == down, :),1);
[dsigs, dps] = ttest2(fbMeans(targets == down, :), restMeans(targets == down, :), ptarg, 'both', 'unequal');
dsigs(isnan(dsigs)) = 0;

% [uvals, usigs] = signedSquaredXCorrValue(fbMeans(targets == up, :), restMeans(targets == up, :), 1, ptarg);
% [dvals, dsigs] = signedSquaredXCorrValue(fbMeans(targets == down, :), restMeans(targets == down, :), 1, ptarg);

usigs(bads) = 0;
dsigs(bads) = 0;

uvals(usigs == 0) = NaN;
dvals(dsigs == 0) = NaN;


if (~exist('doPlots', 'var') || doPlots == true)     
    load('recon_colormap');

    figure;
    PlotDotsDirect(subjid, trodeLocsFromMontage(subjid,Montage,false), ...
        uvals, side, [-max(abs(uvals)) max(abs(uvals))], 20, 'recon_colormap');
    title(sprintf('%s RSAs (fb v r) for all sessions, up targets', subjid));
    colormap(cm);
    colorbar;

    SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), ['overall.' subjid '.up.sm'], 'png');
    maximize;
    SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), ['overall.' subjid '.up.lg'], 'png');
    
    figure;
    PlotDotsDirect(subjid, trodeLocsFromMontage(subjid,Montage,false), ...
        dvals, side, [-max(abs(dvals)) max(abs(dvals))], 20, 'recon_colormap');
    title(sprintf('%s RSAs (fb v r) for all sessions, down targets', subjid));
    colormap(cm);
    colorbar;
    
    SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), ['overall.' subjid '.down.sm'], 'png');
    maximize;
    SaveFig(fullfile(myGetenv('output_dir'), '1DBCI', 'figs'), ['overall.' subjid '.down.lg'], 'png');
end

eval(sprintf('save %s -append usigs dsigs uvals dvals asigs', cachefile));