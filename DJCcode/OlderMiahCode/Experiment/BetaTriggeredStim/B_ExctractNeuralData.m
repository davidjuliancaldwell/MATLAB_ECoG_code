%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject
sid = SIDS{1};
tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
block = 'Block-49';
stims = [54 62];
chans = [61 63];
% chans = 49:64;

% sid = SIDS{2};
% tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
% block = 'BetaPhase-14';
% stims = [55 56];
% chans = [64 63 48];

chans(ismember(chans, stims)) = [];

%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
return
% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];
    
%% process each ecog channel individually
for chan = chans
    
    %% load in ecog data for that channel
    fprintf('loeading in ecog data:\n');
    tic;    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    [eco, efs] = tdt_loadStream(tp, block, ev, achan);

    toc;

    %% process triggers
    presamps = round(0.010 * efs); % pre time in sec
    postsamps = round(0.045 * efs); % post time in sec

    fac = fs/efs;

    if (strcmp(sid, 'd5cd55'))
%         pts = stims(3,:)==0 & (stims(2,:) > 4.5e6);        
        pts = stims(3,:)==0 & (stims(2,:) > 4.5e6) & (stims(2, :) > 36536266);        
    end
    
    if (strcmp(sid, 'c91479'))
        pts = stims(3,:)==0;
    end
    
    ptis = round(stims(2,pts)/fac);

    t = (-presamps:postsamps)/efs;
    
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    % normalize the windows to each other, using pre data
%     awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);

%     % normalize the windows to each other using a single sample just after
%     % stimulus
%     awins = wins-repmat(wins(find(t>7e-3,1,'first'),:), [size(wins, 1), 1]);

%     % normalize the windows to each other removing the median value from
%     % the whole window
%     awins = wins-repmat(median(wins), [size(wins, 1), 1]);

    % normalize the windows to each other, detrending from the pre data to
    % the late data    
%     zwins = wins;
%     zwins(140:200,:) = 0;
    awins = detrend(wins);
    
    pstims = stims(:,pts);
    
    % considered a baseline if it's been at least N seconds since the last
    % burst ended
    
    baselines = pstims(5,:) > 2 * fs;
    
    if (sum(baselines) < 100)
        warning('N baselines = %d.', sum(baselines));
    end

%     % if (all)
%     probes = pstims(5,:) < .250*fs;
%     % if (falling)
    probes = pstims(5,:) < .250*fs * bursts(5,pstims(4,:))==0;
%     if (rising)
%     probes = pstims(5,:) < .250*fs * bursts(5,pstims(4,:))==1;
    
    if (sum(probes) < 100)
        warning('N probes = %d.', sum(probes));        
    end
    
    label = bursts(4,pstims(4,:));
    label(baselines) = 0;

    labelGroupStarts = [1 3 5];
%     labelGroupStarts = 1:5;
    labelGroupEnds   = [labelGroupStarts(2:end) Inf];
    
    for gIdx = 1:length(labelGroupStarts)
        labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
        label(labeli) = gIdx;
    end
    
    keeps = probes | baselines;
    
    load('line_colormap.mat');
    kwins = awins(:, keeps);
    klabel = label(keeps);
    ulabels = unique(klabel);
    colors = cm(round(linspace(1, size(cm, 1), length(ulabels))), :);
    
    %%
    figure
    subplot(2,2,1:2);
    prettyline(1e3*t, 1e6*awins(:, keeps), label(keeps), colors);    
    ylim([-130 50]);
    xlim(1e3*[0 .033]);
%     vline([6 20 40], 'k');
    highlight(gca, [5 20], [], [.8 .8 .8])
    highlight(gca, [25 33], [], [.6 .6 .6])
    
    xlabel('time (ms)');
    ylabel('ECoG (uV)');
    title(sprintf('EP By N_{CT}: %s, %d', sid, chan))
    
    leg = {'Pre'};
    for d = 1:length(labelGroupStarts)
        if d == length(labelGroupStarts)
            leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
        else
            leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
        end        
    end
    leg{end+1} = 'EP_N';
    leg{end+1} = 'EP_P';
    legend(leg)

    dep_n = 1e6*min(awins(t>0.005 & t < 0.020, keeps));
    dep_n = dep_n - mean(dep_n(label(keeps)==0));
    
    dep_p = 1e6*max(awins(t>0.025 & t < 0.033, keeps));
    dep_p = dep_p - mean(dep_p(label(keeps)==0));
    
    subplot(2,2,3);
    prettybar(dep_n, label(keeps), colors, gcf);
    set(gca, 'xtick', []);
    ylabel('\DeltaEP_N (uV)');
    [~,table] = anova1(dep_n', label(keeps), 'off');
    title(sprintf('Change in EP_N by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
    
    pair = {};
    p = [];
    ulabels = unique(label);
    for c = 2:length(ulabels)
        [~,p(c-1)] = ttest2(dep_n(label(keeps)==0), dep_n(label(keeps)==ulabels(c)));
        pair{c-1} = {1,c};
    end
    ylim([-12 15]);
    
    sigstar(pair, p);
    
    subplot(2,2,4);
    prettybar(dep_p, label(keeps), colors, gcf);
    set(gca, 'xtick', []);
    ylabel('\DeltaEP_P (uV)');
    [~,table] = anova1(dep_p', label(keeps), 'off');
    title(sprintf('Change in EP_P by N_{CT}: One-Way Anova F=%4.2f p=%0.4f', table{2,5}, table{2,6}));
    
    pair = {};
    p = [];
    ulabels = unique(label);
    for c = 2:length(ulabels)
        [~,p(c-1)] = ttest2(dep_p(label(keeps)==0), dep_p(label(keeps)==ulabels(c)));
        pair{c-1} = {1,c};
    end
    ylim([-12 15]);
    
    sigstar(pair, p);
    

%     ulabels(ulabels==0) = [];
%     
%     subplot(212);
%             
%     for ulabeli = 1:length(ulabels)
%         ulabel = ulabels(ulabeli);
%         [~,~,~,tstat] = ttest2(kwins(:,klabel==0)', kwins(:, klabel==ulabel)', 'var', 'unequal');
%         plot(1000*t, tstat.tstat, 'color', colors(ulabeli+1, :), 'linew', 2);
%         hold on;
%     end
%     
%     xlim(1e3*[0 .020]);
%     ylim([-10 10]);
%     xlabel('time (ms)');
%     ylabel('difference from baseline (uV)');
    maximize;
    
%     SaveFig(OUTPUT_DIR, sprintf('ep-%s-%d', sid, chan), 'eps', '-r600');    

%     saveFigure(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)));
%     saveas(gcf,fullfile(OUTPUT_DIR, sprintf('ep-%s-%d.eps', sid, chan)),'eps');
end