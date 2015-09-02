%%
Z_Constants;
addpath ./scripts

DO_TIMESERIES = false;
DO_EPOCHS = true;

table = zeros(12, length(SIDS));

%% perform analyses

ctr = 0;

load(fullfile(META_DIR, 'areas.mat'));

tpt = []; tft = []; ppt = []; pft = []; accs = []; subs = [];

for zid = SIDS
    ctr = ctr + 1;
    
    sid = zid{:};
       
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress');
    load(fullfile(META_DIR, [sid '_results']));
    
    [~,~,~,~,cchan] = filesForSubjid(sid);
    trs = trodesOfInterest{ctr};
    if (ismember(cchan, trs))
        warning('dropping the control channel for %s\n', sid);
        trs(trs==cchan) = [];
    end
    
    func = @median;
    
    table(1, ctr) = length(tgts);
    table(2, ctr) = mean(tgts==ress);
    table(4, ctr) = length(trs);
    table(5, ctr) = func(taskpT_hg(trs));
    table(6, ctr) = func(taskfT_hg(trs));
    table(7, ctr) = func(preT_hg(trs));
    table(8, ctr) = func(fbT_hg(trs));
    table(9, ctr) = func(taskpuT_hg(trs));
    table(10, ctr) = func(taskfuT_hg(trs));
    table(11, ctr) = func(taskpdT_hg(trs));
    table(12, ctr) = func(taskfdT_hg(trs));
    
    tpt = cat(1, tpt, taskpT_hg(trs));
    tft = cat(1, tft, taskfT_hg(trs));
    ppt = cat(1, ppt, preT_hg(trs));
    pft = cat(1, pft, fbT_hg(trs));
    
    accs = cat(1, accs, repmat(mean(tgts==ress), length(trs), 1));
    subs = cat(1, subs, repmat(ctr, length(trs), 1));
    
    toc;
end

% disp(table');

% %%
% 
% conds = {{tpt, 'Targeting task-modulated', 'allscatter_taskt', 'PMv activation (rel. rest)'},...
%          {tft, 'Feedback task-modulated', 'allscatter_taskf', 'PMv activation (rel. rest)'},...
%          {ppt, 'Targeting directional', 'allscatter_pre', 'PMv activation (up v down)'},...
%          {pft, 'Feedback directional', 'allscatter_fb', 'PMv activation (up v down)'}};
% 
% for cond = conds
%     figure
%     x = (cond{1}{1});
%     y = accs;
%     
%     legendOff(scatter(x, y));
%     lsline
%     hold on;
%     gscatter(x, y, subs);
%     
%     [r, p] = corr(x, y, 'type','spearman');
%     
%     xlabel(sprintf('PMv Activation (%s)', cond{1}{4}));
%     ylabel('Task performance');
%     
%     l = {};
%     
%     if (p > 0.05)
%         l{1} = sprintf('fit (r = %1.2f, p = %1.2f)', r, p);
%     else
%         l{1} = sprintf('fit (r = %1.2f, p < 0.05)', r);
%     end        
% 
%     for sIdx = 1:length(SIDS)
%         l{end+1} = ['S' num2str(sIdx)];
%     end
%     
%     set(legend(l), 'location', 'EastOutside');
%     
%     title(cond{1}{2});
%     set(gcf, 'pos', [  624   364   913   614]);
%     
%     SaveFig(OUTPUT_DIR, cond{1}{3}, 'png', '-r600');
% end


%% do the statistical plots

conds = {{5, 'Targeting task-modulated', 'scatter_taskt'},...
         {6, 'Feedback task-modulated', 'scatter_taskf'},...
         {7, 'Targeting directional', 'scatter_pre'},...
         {8, 'Feedback directional', 'scatter_fb'}...
         {9, 'Targeting task-modulated (up)', 'scatter_tasktu'},...
         {10, 'Feedback task-modulated (up)', 'scatter_taskfu'},...
         {11, 'Targeting task-modulated (down)', 'scatter_tasktd'},...
         {12, 'Feedback task-modulated (down)', 'scatter_taskfd'}};

for cond = conds
    figure
    x = table(cond{1}{1},:);
    y = table(2,:);
    
    scatter(x, y);
    lsline
    [r, p] = corr(x', y', 'type','spearman');
    
    xlabel('T-statistic');
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

