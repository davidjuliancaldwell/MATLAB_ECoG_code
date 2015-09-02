%% constants
SIDS = {'30052b', 'fc9643'};
SCODES = {'S1', 'S2'};

OUTPUT_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'figures');
META_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'meta');

TouchDir(OUTPUT_DIR);
TouchDir(META_DIR);

addpath(fullfile(myGetenv('matlab_devel_dir'), 'siganal', 'plv'));
tcs;

%% load in the TFA data and do the PLV analyses
for sIdx = 1:length(SIDS)
	subjid = SIDS{sIdx};
	load(fullfile(META_DIR, sprintf('%s-data.mat', subjid)), 'isControl', 'channels', 't', 'tx', 'targets', 'results');
    
    % load in data for the control channel
    load(fullfile(META_DIR, sprintf('%s-decomp-%d.mat', subjid, channels(isControl))), 'win', 'FW');
    cwin = win; clear win;

    % load in data for the learning channel(s) and the non-learning channels(s) on a one by one basis,
    % and perform PLV analyses
    compChannels = channels(~isControl);
    
    for compChannel = compChannels
        load(fullfile(META_DIR, sprintf('%s-decomp-%d.mat', subjid, compChannel)), 'win');
        
        phasors = plvAnalysisFromTFA(cwin(:,FW>=6,:), win(:,FW>=6,:));
                        
        % look at changes in PLV pre to post learning        
        % TODO       
        figure
        switch(sIdx)
            case 1
                split = 33;
            case 2
                split = 53;
        end

        all = squeeze(abs(mean(phasors(t >= tx.fb & t < tx.post, :, :),1)));
        
        subplot(211);        
        
        imagesc(FW(FW>=6),1:size(all,2),zscore(all'))
        ylabel('trials');
        xlabel('frequency (Hz)');
        title('zscored plv during fb');
        ax= hline(split,'k'); set(ax, 'linewidth', 3);
        
        subplot(212);
        
        pre = all(:, 1:split);
        post = all(:, (split+1):end);
        
        errorbar(FW(FW>=6), mean(pre, 2), sem(pre, 2), 'color', theme_colors(red,:), 'linewidth', 1); 
        hold on;
        errorbar(FW(FW>=6), mean(post, 2), sem(post, 2), 'color', theme_colors(blue,:), 'linewidth', 1);
        hold off;
        xlim([0 max(FW)]);
        
        xlabel('frequency (Hz)');
        ylabel('PLV');
        title('PLV during feedback, pre-post');
        legend('pre','post');
        
        SaveFig(OUTPUT_DIR, sprintf('%s-plv-fb-%d-%d', subjid, channels(isControl), compChannel), 'png', '-r300');        
    end
end
