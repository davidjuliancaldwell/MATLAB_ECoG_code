%%
Z_Constants;

DO_TIMESERIES = false;
DO_EPOCHS = true;

table = zeros(8, length(SIDS));

%% perform analyses

ctr = 0;

for zid = SIDS
    ctr = ctr + 1;
    
    sid = zid{:};
       
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress');
    load(fullfile(META_DIR, [sid '_results']));
    
    table(1, ctr) = length(tgts);
    table(2, ctr) = mean(tgts==ress);
    table(4, ctr) = length(taskpH_hg);
    table(5, ctr) = sum(taskpH_hg);
    table(6, ctr) = sum(taskfH_hg);
    table(7, ctr) = sum(preH_hg);
    table(8, ctr) = sum(fbH_hg);
%     table(5, ctr) = taskpT_hg(cchan);
%     table(6, ctr) = taskfT_hg(cchan);
%     table(7, ctr) = preT_hg(cchan);
%     table(8, ctr) = fbT_hg(cchan);
    toc;
end

disp(table');


%% do the statistical plots

conds = {{5, 'Targeting task-modulated', 'scatter_taskt.eps'},...
         {6, 'Feedback task-modulated', 'scatter_taskf.eps'},...
         {7, 'Targeting directional', 'scatter_pre.eps'},...
         {8, 'Feedback directional', 'scatter_fb.eps'}};

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
    
    SaveFig(OUTPUT_DIR, cond{1}{3}, 'eps', '-r600');
end

