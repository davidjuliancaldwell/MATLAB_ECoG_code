%% POSITIVE LAG IMPLIES CONTROL LEADS
Z_Constants;

SID = 1;
CHAN = 2;
TAL = 3:5;
CLASS = 6;
HMAT = 7;
BA = 8;
TYPE = 9;
SIG = 10;
WEIGHT = 11;
TIME = 12;
NUMLAG = 13;

%%
load(fullfile(META_DIR, 'screened_interactions.mat'), '*result*', 'controlLocs');


%% because it's interesting, let's figure out which electrodes changed over 
% the course of learning

%delete
%

changed = zeros(size(resultA, 1), 1);

for sidx = unique(resultA(:,1))'
    sid = SIDS{sidx};
    load(fullfile(META_DIR, [sid '_results']), 'flu*', 'snr*', 'groupRes');
    load(fullfile(META_DIR, [sid '_epochs']),'bad_channels', 'cchan');
        
    decreased = groupRes(:,2) < 0.05 & groupRes(:,1) < 0;
    
    bad_sub = false;
    if (decreased(cchan))
        warning(sprintf('houston we have a problem: %s', sid));
        bad_sub = true;
    end
    
    decreased(union(cchan, bad_channels)) = [];    
    
    idxs = find(resultA(:, SID) == sidx & resultA(:, TYPE) == 1);
    
    if (length(idxs) ~= length(decreased))
        error('we have a different problem');
    end
    
    if (bad_sub)
        changed(idxs) = true;
    else
        changed(idxs) = decreased;
    end
end

%%

% drop the conspicuous subject
badsub = [];
badsub = find(strcmp(SIDS, '38e116'));

changed(ismember(resultA(:,1), badsub)) = [];
resultA(ismember(resultA(:,1), badsub), :) = [];
% resultA(:, LAG) = -resultA(:, LAG);

earlyresultA(ismember(earlyresultA(:,1), badsub), :) = [];
% earlyresultA(:, LAG) = -earlyresultA(:,LAG);

lateresultA(ismember(lateresultA(:,1), badsub), :) = [];
% lateresultA(:, LAG) = -lateresultA(:,LAG);

result(ismember(result(:,1), badsub), :) = [];
% result(:, LAG) = -result(:, LAG);

earlyresult(ismember(earlyresult(:,1), badsub), :) = [];
% earlyresult(:, LAG) = -earlyresult(:, LAG);

lateresult(ismember(lateresult(:,1), badsub), :) = [];
% lateresult(:, LAG) = -lateresult(:, LAG);

%% first some basic stats and observations

for intType = 1:length(INTERACTION_NAMES)
   
    sigints = result(:,TYPE)==intType & result(:, SIG) <= 0.05;
    sigintsearly = sigints & earlyresult(:,TYPE)==intType & earlyresult(:, SIG) <= 0.05;
    sigintslate = sigints & lateresult(:,TYPE)==intType & lateresult(:, SIG) <= 0.05;
    
    sigintsA = resultA(:,TYPE)==intType & resultA(:, SIG) <= 0.05;
    sigintsearlyA = sigintsA & earlyresultA(:,TYPE)==intType & earlyresultA(:, SIG) <= 0.05;
    sigintslateA = sigintsA & lateresultA(:,TYPE)==intType & lateresultA(:, SIG) <= 0.05;
    
    n = length(unique(result(result(:,TYPE)==1 & result(:,SIG)<= 0.05, SID)));
    nA = length(unique(resultA(resultA(:,TYPE)==1 & resultA(:,SIG)<= 0.05, SID)));

    fprintf('there were %d (%d/%d) %s interactions on unaligned data from %d subs\n', sum(sigints), sum(sigintsearly), sum(sigintslate), INTERACTION_NAMES{intType}, n);
    fprintf('       and %d (%d/%d) %s interactions on   aligned data from %d subs\n', sum(sigintsA), sum(sigintsearlyA), sum(sigintslateA), INTERACTION_NAMES{intType}, nA);
end; clear intsOfType sigints* n nA

% %% plot all of the unaligned interactions showing the control electrode (black) and the lags, also encode
% % electrode class by changing the shape
% 
% for sub = {{result, 'unaligned'}, {resultA, 'aligned'}}
%     res = sub{1}{1};
%     name = sub{1}{2};
%     
%     for type = 1:5
%         % determine if there are any significant interactions of this type
%         toshow = res(:,TYPE)==type & res(:,SIG) <= 0.05;
% 
%         if(type==1)
%             if (any(toshow))
%                 figure
% 
%                 % first, plot the control electrodes
%                 subs = unique(res(toshow, 1));
%                 locs = projectToHemisphere(controlLocs, 'r');
%                 PlotDotsDirect('tail', locs(subs, :), ones(length(subs), 1), 'r', [0 1], 20, 'gray', subs, true, true);        
% 
%                 % now plot all of the significant interactions
%                 locs = projectToHemisphere(res(toshow, 3:5), 'r');
%                 weights = res(toshow, LAG);
%                 PlotDotsDirectWithCustomMarkers('tail', locs, weights, 'r', [-max(abs(weights)) max(abs(weights))], 15, res(toshow, CLASS)+1, 'recon_colormap', res(toshow, 1), true);
%                 load('recon_colormap');
%                 colormap(cm);
%                 colorbar;       
% 
%                 title([name ' ' INTERACTION_NAMES{type}]);        
%             end
% 
%             maximize;
%             SaveFig(OUTPUT_DIR, [name '_interactions_cortex'], 'png', '-r600');
%         end
%     end
% end

%% now do plots like the Graz paper
% interaction between lag and interaction strength by class

r_sub = resultA;
er_sub = earlyresultA;
lr_sub = lateresultA;

MAX_P = 0.05;

% keeps = (er_sub(:, SIG) <= MAX_P & er_sub(:, TYPE)==1) | ...
%         (lr_sub(:, SIG) <= MAX_P & lr_sub(:, TYPE)==1) | ... 
%         (r_sub(:,SIG)   <= MAX_P & r_sub(:, TYPE)==1);
keeps = (r_sub(:,SIG)   <= MAX_P & r_sub(:, TYPE)==1);


% keeps = keeps & (r_sub(:,HMAT)==11 | r_sub(:,HMAT)==12);


figure, 

ax = gscatter(r_sub(keeps,WEIGHT), r_sub(keeps,NUMLAG), r_sub(keeps,CLASS), 'rgb');
legend('non-modulated','control-like','effort-like');
hold on;

for axi = (1:length(ax))
    
    axs = ax(axi);
    set(axs,'marker','o');
    set(axs,'markersize',5);
    set(axs,'markerfacecolor',get(axs,'color'));
    set(axs,'markeredgecolor','k');
end

% hline(mean(r_sub(keeps & r_sub(:,CLASS)==1,LAG)), 'r')
% hline(mean(r_sub(keeps & r_sub(:,CLASS)==1,LAG))+sem(r_sub(keeps & r_sub(:,CLASS)==1,LAG),1), 'r:')
% hline(mean(r_sub(keeps & r_sub(:,CLASS)==1,LAG))-sem(r_sub(keeps & r_sub(:,CLASS)==1,LAG),1), 'r:')
% 
% hline(mean(r_sub(keeps & r_sub(:,CLASS)==2,LAG)), 'b')
% hline(mean(r_sub(keeps & r_sub(:,CLASS)==2,LAG))+sem(r_sub(keeps & r_sub(:,CLASS)==2,LAG),1), 'b:')
% hline(mean(r_sub(keeps & r_sub(:,CLASS)==2,LAG))-sem(r_sub(keeps & r_sub(:,CLASS)==2,LAG),1), 'b:')

xlabel('STWC coefficient');
ylabel('Lag (sec) [neg implies ctl leads]');
title ('Interaction between lag and STWC coefficient by class');

ylim([-.3 .3]);
xlim([.1 .5]);

hline(0, 'k:');

set(gcf,'pos',[ 624   692   672   286]);
SaveFig(OUTPUT_DIR, 'scatter', 'eps', '-r600');

%%
    
prettybar(r_sub(keeps,WEIGHT), r_sub(keeps,CLASS),'rgb');
set(gca,'xtick',[1 2 3]);
set(gca,'xticklabel', {'non-modulated','control-like', 'effort-like'});
ylabel('STWC coefficient');
title('STWC coefficient by class');
ylim([-0.01 0.55]);
% set(gcf,'pos',[ 624   692   672   286]);

% version that doesn't correct for correlated observations across subjects
[h, p(1)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==0, WEIGHT), r_sub(keeps & r_sub(:, CLASS)==1, WEIGHT));
[h, p(2)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==1, WEIGHT), r_sub(keeps & r_sub(:, CLASS)==2, WEIGHT));
[h, p(3)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==0, WEIGHT), r_sub(keeps & r_sub(:, CLASS)==2, WEIGHT));

% % version that does
% usubs = unique(r_sub(keeps, 1));
% 
% vals = [];
% for subi = 1:length(usubs)
%     for clazz = 0:2
%         x = r_sub(keeps & r_sub(:, CLASS)==clazz & r_sub(:, SID)==usubs(subi), WEIGHT);
%         if (isempty(x))
%             vals(subi, clazz+1) = NaN;
%         else
%             vals(subi, clazz+1) = median(x);
%         end
%     end
% end

sigstar({{1,2},{2,3},{1, 3}}, p);

SaveFig(OUTPUT_DIR, 'coeffbar', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'coeffbar', 'png', '-r600');

prettybar(r_sub(keeps, NUMLAG), r_sub(keeps, CLASS),'rgb');
set(gca,'xtick',[1 2 3]);
set(gca,'xticklabel', {'non-modulated','control-like', 'effort-like'});
ylabel('Lag (sec) [neg implies ctl leads]');
title('Lag by class');
% set(gcf,'pos',[ 624   692   672   286]);

[h, p(1)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==0, NUMLAG), r_sub(keeps & r_sub(:, CLASS)==1, NUMLAG));
[h, p(2)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==1, NUMLAG), r_sub(keeps & r_sub(:, CLASS)==2, NUMLAG));
[h, p(3)] = ttest2(r_sub(keeps & r_sub(:, CLASS)==0, NUMLAG), r_sub(keeps & r_sub(:, CLASS)==2, NUMLAG));

sigstar({{1,2},{2,3},{1, 3}}, p);
set(gca,'ylim', [-.11 .11]);
SaveFig(OUTPUT_DIR, 'lagbar', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'lagbar', 'png', '-r600');

%% and then do the early/late comparison

% ekeeps = (er_sub(:, SIG) <= 0.05 & er_sub(:, TYPE)==1);
ekeeps = keeps;
% lkeeps = (lr_sub(:, SIG) <= 0.05 & lr_sub(:, TYPE)==1);
lkeeps = keeps;

ctr = 0;
figures(1) = figure;
figures(2) = figure;

% N = 2;
% for idx = {{WEIGHT, 'STWC coefficient', [-0.01 0.55], false}, {NUMLAG, 'Lag (bin)', [-1 1], true}}   
N = 1;
for idx = {{WEIGHT, 'STWC coefficient', [-0.01 0.55], false}}   
    ctr = ctr + 1;
    n = idx{1}{1};
    s = idx{1}{2};
    ys = idx{1}{3};
    zcomp = idx{1}{4};
    
    coms = {}; p = [];
    
    a = arrayfun(@(x) median(earlyresultA(earlyresultA(:, 1)==x&ekeeps, n)), unique(earlyresultA(ekeeps, 1)));
    b = arrayfun(@(x) median(lateresultA(lateresultA(:, 1)==x&lkeeps, n)), unique(lateresultA(lkeeps, 1)));
    
    a_corr = arrayfun(@(x) median(earlyresultA(earlyresultA(:, 1)==x&ekeeps&~changed, n)), unique(earlyresultA(ekeeps, 1)));
    b_corr = arrayfun(@(x) median(lateresultA(lateresultA(:, 1)==x&lkeeps&~changed, n)), unique(lateresultA(lkeeps, 1)));
    
    if (zcomp)
        % are they different from zero
        [~, p(1)] = ttest(er_sub(ekeeps,n));
        coms{1} = {1,1};

        [~, p(2)] = ttest(lr_sub(ekeeps,n));
        coms{2} = {2,2};
        
        % are they different from each other
        [h, p(3)] = ttest(er_sub(ekeeps,n), lr_sub(ekeeps,n));        
        coms{3} = {1,2};        
    else
        % are they different from each other
%         [h, p] = ttest(er_sub(ekeeps,n), lr_sub(ekeeps,n));
        [h, p] = ttest(a, b);
        coms{1} = {1,2};
        
        [h_corr, p_corr] = ttest(a_corr, b_corr);        
    end
        
    figure(figures(1))
    subplot(1, N, ctr);
    bar(mean([a b]), 'edgecolor', 'k', 'facecolor', [.5 .5 .5], 'linew', 2);
    hold on;
    ax = errorbar(mean([a b]), sem([a b]), 'k');
    set(ax, 'linestyle', 'none');
    set(ax, 'linew', 3);
   
    ylabel(s, 'fontsize', 18);
    title('Change in STWC Coefficient', 'fontsize', 18);
    set(gca, 'fontsize', 14);
    set(gca, 'xticklabel', {'Early', 'Late'});
   
    ylim(ys);
    sigstar(coms, p);        
    
    figure(figures(2))
    subplot(1, N, ctr);
    bar(nanmean([a_corr b_corr]), 'edgecolor', 'k', 'facecolor', [.5 .5 .5], 'linew', 2);
    hold on;
    ax = errorbar(nanmean([a_corr b_corr]), nansem([a_corr b_corr]), 'k');
    set(ax, 'linestyle', 'none');
    set(ax, 'linew', 3);
   
    ylabel(s, 'fontsize', 18);
    title('Change in STWC Coefficient (corrected)', 'fontsize', 18);
    set(gca, 'fontsize', 14);
    set(gca, 'xticklabel', {'Early', 'Late'});
   
    ylim(ys);
    sigstar(coms, p_corr);        
    
end

%%
figure(figures(1)); 
SaveFig(OUTPUT_DIR, 'early-late-overall', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'early-late-overall', 'png', '-r600');

figure(figures(2)); 
SaveFig(OUTPUT_DIR, 'early-late-overall-corrected', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'early-late-overall-corrected', 'png', '-r600');

%%
ec0 = ekeeps & er_sub(:, CLASS) == 0;
lc0 = ekeeps & lr_sub(:, CLASS) == 0;
ec1 = ekeeps & er_sub(:, CLASS) == 1;
lc1 = lkeeps & lr_sub(:, CLASS) == 1;
ec2 = ekeeps & er_sub(:, CLASS) == 2;
lc2 = lkeeps & lr_sub(:, CLASS) == 2;

figure
cidx = 0;

if (ischar(classcolors))
    cl = classcolors(cidx==classes);
else
    cl = classcolors(:, cidx==classes);
end

bar([mean(er_sub(ec0,WEIGHT)), mean(lr_sub(lc0,WEIGHT))], 'edgecolor', 'k', 'facecolor', cl, 'linew', 2);
hold on;
ax = errorbar([mean(er_sub(ec0,WEIGHT)), mean(lr_sub(lc0,WEIGHT))], [sem(er_sub(ec0,WEIGHT)), sem(lr_sub(lc0,WEIGHT))], 'k');
set(ax, 'linestyle', 'none');
set(ax, 'linew', 3);

ylabel(s, 'fontsize', 18);
set(gca, 'xticklabel', {'Early', 'Late'});
title(classnames{find(cidx==classes)}, 'fontsize', 18);
set(gca, 'fontsize', 14);
                
ylim([-0.01 0.55]);
[~, sp] = ttest(er_sub(ec0,n), lr_sub(lc0,n));
sigstar(coms, sp);  

SaveFig(OUTPUT_DIR, 'early-late-weight-nonmod', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'early-late-weight-nonmod', 'png', '-r600');



figure
cidx = 1;
if (ischar(classcolors))
    cl = classcolors(cidx==classes);
else
    cl = classcolors(:, cidx==classes);
end
bar([mean(er_sub(ec1,WEIGHT)), mean(lr_sub(lc1,WEIGHT))], 'edgecolor', 'k', 'facecolor', cl, 'linew', 2);
hold on;
ax = errorbar([mean(er_sub(ec1,WEIGHT)), mean(lr_sub(lc1,WEIGHT))], [sem(er_sub(ec1,WEIGHT)), sem(lr_sub(lc1,WEIGHT))], 'k');
set(ax, 'linestyle', 'none');
set(ax, 'linew', 3);

ylabel(s, 'fontsize', 18);
set(gca, 'xticklabel', {'Early', 'Late'});
title(classnames{find(cidx==classes)}, 'fontsize', 18);
set(gca, 'fontsize', 14);

ylim([-0.01 0.55]);
[~, sp] = ttest(er_sub(ec1,n), lr_sub(lc1,n));
sigstar(coms, sp);  

SaveFig(OUTPUT_DIR, 'early-late-weight-ctllike', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'early-late-weight-ctllike', 'png', '-r600');


figure
cidx = 2;
if (ischar(classcolors))
    cl = classcolors(cidx==classes);
else
    cl = classcolors(:, cidx==classes);
end
bar([mean(er_sub(ec2,WEIGHT)), mean(lr_sub(lc2,WEIGHT))], 'edgecolor', 'k', 'facecolor', cl, 'linew', 2);
hold on;
ax = errorbar([mean(er_sub(ec2,WEIGHT)), mean(lr_sub(lc2,WEIGHT))], [sem(er_sub(ec2,WEIGHT)), sem(lr_sub(lc2,WEIGHT))], 'k');
set(ax, 'linestyle', 'none');
set(ax, 'linew', 3);

ylabel(s, 'fontsize', 18);
set(gca, 'xticklabel', {'Early', 'Late'});
title(classnames{find(cidx==classes)}, 'fontsize', 18);
set(gca, 'fontsize', 14);

ylim([-0.01 0.55]);
[~, sp] = ttest(er_sub(ec2,n), lr_sub(lc2,n));
sigstar(coms, sp);  

SaveFig(OUTPUT_DIR, 'early-late-weight-effort', 'eps', '-r600');
SaveFig(OUTPUT_DIR, 'early-late-weight-effort', 'png', '-r600');


















% warning ('hardcoded significance values because i am lazy')
% sigstar({{3 3}, {2 3}});

% set(gcf,'pos',[ 624   692   672   286]);
% SaveFig(OUTPUT_DIR, 'lagbar', 'eps', '-r600');

% %% stats on mean lags and times for classes
% ASSUME_NORMAL = true;
% 
% fprintf('summary\n');
% fprintf(' trode counts: %d (%d %d %d)\n', length(trodes), sum(trodes(:,6)==0) , sum(trodes(:,6)==1) , sum(trodes(:,6)==2) );
% 
% for featpair = {{7, 'corr'},{9, 'lag'}}    
%     feat = featpair{1}{1};
%     featstr = featpair{1}{2};
%     
%     [h, p] = ttest(trodes(:, feat));
%     if (h==1)
%         fprintf(' PMv %s was significant @ p = %0.4f\n', featstr, p);
%     else
%         fprintf(' PMv %s was NOT significant @ p = %0.4f\n', featstr, p);
%     end
% 
%     for iclass = 0:2
%         [h, p] = ttest(trodes(trodes(:,6)==iclass, feat));
%         
%         lg = mean(trodes(trodes(:,6)==iclass, feat));
%         lgs = sem(trodes(trodes(:,6)==iclass, feat));
%         if (h==1)
%             fprintf(' %s (%0.4f, %0.4f) for class %d was significant @ p = %0.4f\n', featstr, lg, lgs, iclass, p);
%         else
%             fprintf(' %s (%0.4f, %0.4f) for class %d was NOT significant @ p = %0.4f\n', featstr, lg, lgs, iclass, p);
%         end
%     end
% 
%     for pair = nchoosek(0:2, 2)'
%         if (ASSUME_NORMAL)
%             [h, p] = ttest2(trodes(trodes(:,6)==pair(1), feat), trodes(trodes(:,6)==pair(2), feat));
%         else
%             [p, h] = ranksum(trodes(trodes(:,6)==pair(1), feat), trodes(trodes(:,6)==pair(2), feat));
%         end
%         lg = mean(trodes(trodes(:,6)==pair(1), feat)) - mean(trodes(trodes(:,6)==pair(2), feat));
%         if (h==1)
%             fprintf(' %s (%0.4f) difference for %d<=>%d was significant @ p = %0.4f\n', featstr, lg, pair(1), pair(2), p);
%         else
%             fprintf(' %s (%0.4f) difference for %d<=>%d was NOT significant @ p = %0.4f\n', featstr, lg, pair(1), pair(2), p);
%         end
%     end
% end
