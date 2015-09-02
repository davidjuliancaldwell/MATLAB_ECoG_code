Z_Constants;

load temp

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

%%
weight = 7;
time = 8;
lag = 9;

ctr = 0;
figures(1) = figure;

for idx = {{weight, 'STWC coefficient', [-0.01 0.55], false}, {lag, 'Lag (sec)', [-0.13 0.18], true}}   
    ctr = ctr + 1;
    n = idx{1}{1};
    s = idx{1}{2};
    ys = idx{1}{3};
    zcomp = idx{1}{4};
    
    coms = {}; p = [];
    
    if (zcomp)
        % are they different from zero
        [~, p(1)] = ttest(etrodes(:,n));
        coms{1} = {1,1};

        [~, p(2)] = ttest(ltrodes(:,n));
        coms{2} = {2,2};
        
        % are they different from each other
        [h, p(3)] = ttest(etrodes(:,n), ltrodes(:,n));        
        coms{3} = {1,2};        
    else
        % are they different from each other
        [h, p] = ttest(etrodes(:,n), ltrodes(:,n));
        coms{1} = {1,2};
    end
    
    
    
    figure(figures(1))
    subplot(1, 2, ctr);
    bar([mean(etrodes(:,n)), mean(ltrodes(:,n))], 'edgecolor', 'k', 'facecolor', [.5 .5 .5], 'linew', 2);
    hold on;
    ax = errorbar([mean(etrodes(:,n)), mean(ltrodes(:,n))], [sem(etrodes(:,n)), sem(ltrodes(:,n))], 'k');
    set(ax, 'linestyle', 'none');
    set(ax, 'linew', 3);
   
    ylabel(s, 'fontsize', 14);
    title('All classes', 'fontsize', 14);
    set(gca, 'xticklabel', {'Early', 'Late'});
    set(gca, 'xlim', [.5 2.5]);
    set(gca, 'fontsize', 14);
    
    ylim(ys);
    sigstar(coms, p);
    

    classcolors = 'rgb';
    figures(ctr+1) = figure;
    
    classes = 0:2;
    classnames = {'Non-modulated', 'Control-like', 'Effort-like'};
    
    for cidx = 1:length(classes)
        subplot(1,3,cidx);
        
        % are they different by class
        ei = etrodes(:,6)==classes(cidx);
        li = ltrodes(:,6)==classes(cidx);

        sp = [];
        
        if (zcomp)
            % are they different from zero
            [~, sp(1)] = ttest(etrodes(ei,n));
            [~, sp(2)] = ttest(ltrodes(li,n));
            
            % are they different from each other
            [~, sp(3)] = ttest(etrodes(ei,n), ltrodes(li,n));        
        else
            % are they different from each other    
            [~, sp] = ttest(etrodes(ei,n), ltrodes(li,n));
        end
        
        
        bar([mean(etrodes(ei,n)), mean(ltrodes(li,n))], 'edgecolor', 'k', 'facecolor', classcolors(cidx), 'linew', 2);
        hold on;
        ax = errorbar([mean(etrodes(ei,n)), mean(ltrodes(li,n))], [sem(etrodes(ei,n)), sem(ltrodes(li,n))], 'k');
        set(ax, 'linestyle', 'none');
        set(ax, 'linew', 3);

        ylabel(s, 'fontsize', 14);
        set(gca, 'xticklabel', {'Early', 'Late'});
        title(classnames{cidx}, 'fontsize', 14);
        set(gca, 'xlim', [.5 2.5]);
        set(gca, 'fontsize', 14);                
        
        ylim(ys);
        sigstar(coms, sp);  
        
%         [er,ep] = corr(etrodes(ei,n), accs)
%         [lr,lp] = corr(ltrodes(li,n), accs)
    end 
    
end

%%
figure(figures(1)); 
SaveFig(OUTPUT_DIR, 'early-late-overall', 'eps', '-r600');

figure(figures(2)); 
set(gcf, 'pos', [ 624         474        1033         504]);    
SaveFig(OUTPUT_DIR, 'early-late-peak-class', 'eps', '-r600');

figure(figures(3)); 
set(gcf, 'pos', [ 624         474        1033         504]);    
SaveFig(OUTPUT_DIR, 'early-late-lag-class', 'eps', '-r600');