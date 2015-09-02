load temp
Z_Constants;


%% remove the non-significant electrodes
load(fullfile(META_DIR,'graz','thresholds.mat'));

keep = threshold(trodes(:,1)) < trodes(:,7)';
ekeep = earlyThreshold(etrodes(:,1)) < etrodes(:,7)';
lkeep = lateThreshold(ltrodes(:,1)) < ltrodes(:,7)';

sum(keep)
trodes = trodes(keep|ekeep|lkeep, :);

sum(ekeep)
etrodes = etrodes(ekeep|lkeep|keep, :);

sum(lkeep)
ltrodes = ltrodes(lkeep|ekeep|keep, :);

sum(lkeep|ekeep|keep)

%% interaction between lag and interaction strength by class
figure, 

% groups = {};
% for c = 1:size(trodes,1)
%     switch(trodes(c,6))
%         case 0
%             groups{c} = 'non-modulated';
%         case 1
%             groups{c} = 'control-like';
%         case 2
%             groups{c} = 'effort-like';
%     end
% end

hold on;
ax = gscatter(trodes(:,7), trodes(:,9), trodes(:,6), [1 0 0; 0 1 0; 0 0 1]);
leg = legend('non-modulated','control-like','effort-like');
set(leg, 'fontsize', 12);

for axi = (1:length(ax))
    
    axs = ax(axi);
    set(axs,'marker','o');
    set(axs,'markersize',5);
    set(axs,'markerfacecolor',get(axs,'color'));
    set(axs,'markeredgecolor','k');
end


xlabel('STWC coefficient', 'fontsize', 14);
ylabel('Lag (sec)', 'fontsize', 14);
title ('Interaction between lag and STWC coefficient by class', 'fontsize', 14);
set(gca, 'fontsize', 14);

% axis ij;
ylim([-.4 .4]);
xlim([.1 .5]);

hline(0, 'k:');

set(gcf,'pos',[ 624   692   672   286]);
SaveFig(OUTPUT_DIR, 'scatter', 'eps', '-r600');

prettybar(trodes(:,7), trodes(:,6), 'rgb');
set(gca,'xtick',[1 2 3]);
set(gca,'xticklabel', {'non-modulated', 'control-like', 'effort-like'});
ylabel('STWC coefficient', 'fontsize', 14);
title('STWC coefficient by class', 'fontsize', 14);
set(gca, 'fontsize', 14);

set(gcf,'pos',[ 624   692   672   286]);
SaveFig(OUTPUT_DIR, 'coeffbar', 'eps', '-r600');

prettybar(trodes(:,9), trodes(:,6), 'rgb');
set(gca,'xtick',[1 2 3]);
set(gca,'xticklabel', {'non-modulated', 'control-like', 'effort-like'});
ylabel('Lag (sec)', 'fontsize', 14);
title('Lag by class', 'fontsize', 14);
set(gca, 'fontsize', 14);
warning ('hardcoded significance values because i am lazy')
sigstar({{3 3}, {2 3}});
% axis ij;
set(gcf,'pos',[ 624   692   672   286]);
SaveFig(OUTPUT_DIR, 'lagbar', 'eps', '-r600');

%% stats on mean lags and times for classes
ASSUME_NORMAL = true;

fprintf('summary\n');
fprintf(' trode counts: %d (%d %d %d)\n', length(trodes), sum(trodes(:,6)==0) , sum(trodes(:,6)==1) , sum(trodes(:,6)==2) );

for featpair = {{7, 'corr'},{9, 'lag'}}    
    feat = featpair{1}{1};
    featstr = featpair{1}{2};
    
    [h, p] = ttest(trodes(:, feat));
    if (h==1)
        fprintf(' PMv %s was significant @ p = %0.4f\n', featstr, p);
    else
        fprintf(' PMv %s was NOT significant @ p = %0.4f\n', featstr, p);
    end

    for iclass = 0:2
        [h, p] = ttest(trodes(trodes(:,6)==iclass, feat));
        
        lg = mean(trodes(trodes(:,6)==iclass, feat));
        lgs = sem(trodes(trodes(:,6)==iclass, feat));
        if (h==1)
            fprintf(' %s (%0.4f, %0.4f) for class %d was significant @ p = %0.4f\n', featstr, lg, lgs, iclass, p);
        else
            fprintf(' %s (%0.4f, %0.4f) for class %d was NOT significant @ p = %0.4f\n', featstr, lg, lgs, iclass, p);
        end
    end

    for pair = nchoosek(0:2, 2)'
        if (ASSUME_NORMAL)
            [h, p] = ttest2(trodes(trodes(:,6)==pair(1), feat), trodes(trodes(:,6)==pair(2), feat));
        else
            [p, h] = ranksum(trodes(trodes(:,6)==pair(1), feat), trodes(trodes(:,6)==pair(2), feat));
        end
        lg = mean(trodes(trodes(:,6)==pair(1), feat)) - mean(trodes(trodes(:,6)==pair(2), feat));
        if (h==1)
            fprintf(' %s (%0.4f) difference for %d<=>%d was significant @ p = %0.4f\n', featstr, lg, pair(1), pair(2), p);
        else
            fprintf(' %s (%0.4f) difference for %d<=>%d was NOT significant @ p = %0.4f\n', featstr, lg, pair(1), pair(2), p);
        end
    end
end

% %%
% 
% fprintf('accuracy');
% 
% cl = trodes(:,6)==1 | trodes(:,6)==0 ;
% gscatter(trodes(cl,9), trodes(cl,10), trodes(cl,1));
% 
% for featpair = {{7, 'corr'},{9, 'lag'}}    
%     feat = featpair{1}{1};
%     featstr = featpair{1}{2};
% 
%     for sidx = unique(trodes(:,1))'
%         tidx = trodes(:,1)==sidx;
%         max(trodes(tidx, feat))
%     end
% end

% [r,p]=corr(trodes(:,6),trodes(:,10))
% [r,p]=corr(trodes(:,7),trodes(:,10))
% [r,p]=corr(trodes(:,9),trodes(:,10))

% locs = trodes(:, 3:5);
% locs(:, 1) = abs(locs(:, 1))+3;
% % % 
% figure;
% PlotDotsDirect('tail', locs, trodes(:,6),'r',[0 2], 5, 'recon_colormap', [], false);
% title('class'); load('recon_colormap'); colormap(cm); colorbar;
% % % 
% % figure;
% % PlotDotsDirect('tail', locs, trodes(:,7),'r',[min(trodes(:,7)) max(trodes(:,7))], 5, 'recon_colormap', [], false);
% % title('weight');
% % % 
% % % figure;
% % % PlotDotsDirect('tail', locs, trodes(:,8),'r',[min(trodes(:,8)) max(trodes(:,8))], 5, 'recon_colormap', [], false);
% % % title('tcenter');
% % % 
% figure;
% PlotDotsDirect('tail', locs, trodes(:,9),'r',[min(trodes(:,9)) max(trodes(:,9))], 5, 'recon_colormap', [], false);
% title('lcenter');
