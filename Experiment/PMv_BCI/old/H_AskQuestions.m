%%

error ('incomplete');

Z_Constants;
addpath ./scripts

DO_TIMESERIES = false;
DO_EPOCHS = true;

load(fullfile(META_DIR, 'areas.mat'));


%% set up

ctr = 0;
for zid = SIDS
    ctr = ctr + 1;
    sid = zid{:};
       
    %% set up to work on this subject
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress', 'epochs_hg', 't', '*Dur');
    [~,~,~,~,cchan] = filesForSubjid(sid);
    trs = trodesOfInterest{ctr};    
    
    data(ctr).epochs = epochs_hg;
    data(ctr).t = t;
    data(ctr).preDur = preDur;
    data(ctr).fbDur = fbDur;
    data(ctr).trs = trodesOfInterest{ctr};
    data(ctr).cchan = cchan;
    data(ctr).tgts = tgts;
    data(ctr).ress = ress;
end; clear tgts ress epochs_hg t *Dur zid sid ctr

%% Question 1

% conditions
%  during targeting: t < 0 & t > -fbDur
%  non-control activity: channels = trs(~ismember(trs, cchan))
%   vs.
%  task-performance on all target types: acc = mean(tgts==ress)

x = [];
y = [];
l = [];

for idx = 1:length(data)
    cs = data(idx).trs(~ismember(data(idx).trs, data(idx).cchan));
    mx = mean(data(idx).epochs(cs,:, data(idx).t < 0 & data(idx).t > -data(idx).preDur), 3);
    return
    my = repmat(mean(data(idx).tgts==data(idx).ress), size(cs));
    l = repmat(idx, size(cs));
end; clear mx my cs

multiObsGScatter(x, y, l, @median);

return
%%
% disp(table');

%%

conds = {{tpt, 'Targeting task-modulated', 'allscatter_taskt', 'PMv activation (rel. rest)'},...
         {tft, 'Feedback task-modulated', 'allscatter_taskf', 'PMv activation (rel. rest)'},...
         {ppt, 'Targeting directional', 'allscatter_pre', 'PMv activation (up v down)'},...
         {pft, 'Feedback directional', 'allscatter_fb', 'PMv activation (up v down)'}};

for cond = conds
    figure
    x = (cond{1}{1});
    y = accs;
    
    legendOff(scatter(x, y));
    lsline
    hold on;
    gscatter(x, y, subs);
    
    [r, p] = corr(x, y, 'type','spearman');
    
    xlabel(sprintf('PMv Activation (%s)', cond{1}{4}));
    ylabel('Task performance');
    
    l = {};
    
    if (p > 0.05)
        l{1} = sprintf('fit (r = %1.2f, p = %1.2f)', r, p);
    else
        l{1} = sprintf('fit (r = %1.2f, p < 0.05)', r);
    end        

    for sIdx = 1:length(SIDS)
        l{end+1} = ['S' num2str(sIdx)];
    end
    
    set(legend(l), 'location', 'EastOutside');
    
    title(cond{1}{2});
    set(gcf, 'pos', [  624   364   913   614]);
    
    SaveFig(OUTPUT_DIR, cond{1}{3}, 'png', '-r600');
end


%% do the statistical plots

conds = {{5, 'Targeting task-modulated', 'scatter_taskt'},...
         {6, 'Feedback task-modulated', 'scatter_taskf'},...
         {7, 'Targeting directional', 'scatter_pre'},...
         {8, 'Feedback directional', 'scatter_fb'}...
         {9, 'Targeting task-modulated', 'scatter_tasktu'},...
         {10, 'Feedback task-modulated', 'scatter_taskfu'},...
         {11, 'Targeting task-modulated', 'scatter_tasktd'},...
         {12, 'Feedback task-modulated', 'scatter_taskfd'}};

for cond = conds
    figure
    x = table(cond{1}{1},:);
    y = table(2,:);
    
    scatter(x, y);
    lsline
    [r, p] = corr(x', y', 'type','spearman');
    
    xlabel('Number of electrodes');
    ylabel('Task performance');
    
    if (p > 0.05)
        legend('individuals', sprintf('fit (r = %1.2f, p = %1.2f)', r, p), 'location', 'SouthOutside');
    else
        legend('individuals', sprintf('fit (r = %1.2f, p < 0.05)', r), 'location', 'SouthOutside');
    end        
    
    title(cond{1}{2});
    set(gcf, 'pos', [ 624   364   672   614]);
    
    SaveFig(OUTPUT_DIR, cond{1}{3}, 'png', '-r600');
end

