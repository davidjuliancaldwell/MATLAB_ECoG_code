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
        
        % look at changes in PLV rest to fb
        figure;
        
        pdata = abs(mean(phasors, 3));
        pnorm = normalize_plv(pdata', pdata(t > .2 & t < 1, :)');
        imagesc(t,FW(FW>=6),pnorm)
        axis xy;
        vline([tx.fb tx.pre tx.post]);
        title('all targets');
        xlabel('time (s)');
        ylabel('frequency (hz)');
        colorbar;
        set_colormap_threshold(gcf, [-2 2], [-7 7], [.5 .5 .5])
        
        SaveFig(OUTPUT_DIR, sprintf('%s-plv-all-%d-%d', subjid, channels(isControl), compChannel), 'png', '-r600');
        
%         
%         subplot(223);
%         imagesc(t,FW,abs(mean(phasors(:,:,targets==1),3))');
%         axis xy;
%         vline([tx.fb tx.pre tx.post]);
%         title('up targets');
%         xlabel('time (s)');
%         ylabel('frequency (hz)');
%         colorbar;
%         
%         subplot(224);
%         imagesc(t,FW,abs(mean(phasors(:,:,targets==2),3))');
%         axis xy;
%         vline([tx.fb tx.pre tx.post]);
%         title('down targets');
%         xlabel('time (s)');
%         ylabel('frequency (hz)');
%         colorbar;
                
        % look at changes in PLV pre to post learning        
        % TODO       
        figure
        switch(sIdx)
            case 1
                split = 33;
            case 2
                split = 53;
        end
        
        subplot(211);        
        pdata = abs(mean(phasors(:,:,1:split), 3));
        pnorm = normalize_plv(pdata', pdata(t > .2 & t < 1, :)');
        imagesc(t,FW(FW>=6),pnorm)
        axis xy;
        vline([tx.fb tx.pre tx.post]);
        title('early targets');
        xlabel('time (s)');
        ylabel('frequency (hz)');
        colorbar;
        set_colormap_threshold(gcf, [-2 2], [-7 7], [.5 .5 .5])
        
        subplot(212);        
        pdata = abs(mean(phasors(:,:,(split+1):end), 3));
        pnorm = normalize_plv(pdata', pdata(t > .2 & t < 1, :)');
        imagesc(t,FW(FW>=6),pnorm)
        axis xy;
        vline([tx.fb tx.pre tx.post]);
        title('late targets');
        xlabel('time (s)');
        ylabel('frequency (hz)');
        colorbar;
        set_colormap_threshold(gcf, [-2 2], [-7 7], [.5 .5 .5])
        
        SaveFig(OUTPUT_DIR, sprintf('%s-plv-split-%d-%d', subjid, channels(isControl), compChannel), 'png', '-r600');        
    end
end
