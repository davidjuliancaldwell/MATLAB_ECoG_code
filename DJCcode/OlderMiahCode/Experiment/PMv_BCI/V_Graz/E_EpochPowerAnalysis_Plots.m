%%
Z_Constants;

DO_TIMESERIES = true;
DO_EPOCHS = false;

%%
earlyL = [];
lateL = [];
classes = [];

ctr = 0;
for zid = SIDS
    sid = zid{:};
    ctr = ctr + 1;
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
        
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress', 'montage', 'cchan');
    
    if (DO_TIMESERIES)
        load(fullfile(META_DIR, [sid '_epochs']));
    end
    
    load(fullfile(META_DIR, [sid '_results']));

    ups = tgts == 1;
    
    subjOutputDir = fullfile(OUTPUT_DIR, sid);
    TouchDir(subjOutputDir);

    toc;
    
    %% Generate plots for time series of ups vs down trials, these will be saved in subject specific directories
    % for the sake of sanity
    load(fullfile(META_DIR, 'areas.mat'));

    trs = trodesOfInterest{ctr};
    trs(trs==cchan) = [];
    
    if (DO_TIMESERIES)
        fprintf(' generating timeseries figures: ');
        tic;
        
%         for chan = 1:size(epochs_hg, 1)
        for chan = union(cchan, trodesOfInterest{ctr})'
            figure;
            prettyline(t, GaussianSmooth(squeeze(epochs_hg(chan, :, :)), fs*.25), tgts)
            
            ax(1) = vline(-preDur, 'k');
            ax(2) = vline(0, 'k');
            ax(3) = vline(fbDur, 'k');
            set(ax, 'linew', 2);

            xlabel('time (s)');
            ylabel('|HG|');
            if (chan == cchan)
                title([sid ' ' trodeNameFromMontage(chan, montage) ' (control channel)']);
            else
                title([sid ' ' trodeNameFromMontage(chan, montage)]);
            end
            
            legend('Up', 'Down');
            SaveFig(subjOutputDir, ['ts_' num2str(chan)], 'eps', '-r600');
            close;
        end    
        toc;    
    end
    
    %% perform analyses for mean activation by in the pre phase and the fb phase    
    trodes = [cchan; trs(trs~=cchan)];
    
    if (DO_EPOCHS)
        fprintf(' generating epoch-based plots: ');
        tic;
        figure

        amu = zeros(length(trodes)*3, 1);
        asem = zeros(length(trodes)*3, 1);
                
        groups = cell(length(trodes),1);
        ticks = [];
        labels = {};
        for gIdx = 1:length(groups)
            groups{gIdx} = (gIdx-1)*3 + [1 2];
            ticks(end+1) = (gIdx-1)*3 + 1.5;
%             labels{end+1} = trodeNameFromMontage(trodes(gIdx), montage);
            labels{end+1} = num2str(trodes(gIdx));
        end
        
        % feedback vs rest
        subplot(311);
        amu(1:3:end) = mean(rest_hg(trodes, :),2);
        asem(1:3:end) = sem(rest_hg(trodes, :),2);
        amu(2:3:end) = mean(fb_hg(trodes, :),2);
        asem(2:3:end) = sem(fb_hg(trodes, :),2);
        
        ax = bar(amu);        
        hold on;
        ax = errorbar(amu, asem, 'k');
        set(ax, 'linestyle', 'none');       
        sigstar(groups, taskfP_hg(trodes));        
        set(gca, 'xtick', ticks);
        set(gca, 'xticklabel', labels);        
        title('rest vs feedback');
        
        % feedback vs rest (ups)
        subplot(312);
        amu(1:3:end) = mean(rest_hg(trodes, tgts==1),2);
        asem(1:3:end) = sem(rest_hg(trodes, tgts==1),2);
        amu(2:3:end) = mean(fb_hg(trodes, tgts==1),2);
        asem(2:3:end) = sem(fb_hg(trodes, tgts==1),2);
        
        ax = bar(amu);        
        hold on;
        ax = errorbar(amu, asem, 'k');
        set(ax, 'linestyle', 'none');       
        sigstar(groups, taskfuP_hg(trodes));        
        set(gca, 'xtick', ticks);
        set(gca, 'xticklabel', labels);        
        title('rest vs feedback (up targets)');
        
        % feedback vs rest (downs)
        subplot(313);
        amu(1:3:end) = mean(rest_hg(trodes, tgts==2),2);
        asem(1:3:end) = sem(rest_hg(trodes, tgts==2),2);
        amu(2:3:end) = mean(fb_hg(trodes, tgts==2),2);
        asem(2:3:end) = sem(fb_hg(trodes, tgts==2),2);
        
        ax = bar(amu);        
        hold on;
        ax = errorbar(amu, asem, 'k');
        set(ax, 'linestyle', 'none');       
        sigstar(groups, taskfdP_hg(trodes));        
        set(gca, 'xtick', ticks);
        set(gca, 'xticklabel', labels);        
        title('rest vs feedback (down targets)');
        
        mtit(sid, 'xoff', 0, 'yoff', 0.05);
        set(gcf, 'pos', [624   163   672   815]);
        
        SaveFig(OUTPUT_DIR, sprintf('%s-epoch_act',sid), 'png', '-r600');
        
        toc;   
    end  
    
    
    half = true(size(tgts));
    half(ceil(length(half)/2):end) = 0;

    early = tgts == 1 & ress == 1 & half;
    late = tgts == 1 & ress == 1 & ~half;
    
    h = ttest2(fb_hg(trodes, early), fb_hg(trodes, late), 'dim', 2)
        
    class(trodes(1)) = -1; % force the control channel to -1
    
    classes = cat(1, classes, class(trodes(h==1)));
    earlyL(ctr) = sum(early);
    lateL(ctr) = sum(late);
end

fprintf('range of earlies: (%d, %d)\n' , min(earlyL), max(earlyL));
fprintf('range of lates: (%d, %d)\n' , min(lateL), max(lateL));

