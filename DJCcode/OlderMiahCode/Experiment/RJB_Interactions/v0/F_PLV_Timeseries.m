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
    
    if (sIdx == 1) compChannels = 43;
    else           compChannels = 19;
    end
        
    for compChannel = compChannels
        load(fullfile(META_DIR, sprintf('%s-decomp-%d.mat', subjid, compChannel)), 'win');
        
        phasors = plvAnalysisFromTFA(cwin, win);
                        
        % look at changes in PLV pre to post learning        
        % TODO       
        
        switch(sIdx)
            case 1
                split = 33;
            case 2
                split = 50;
        end

        isEarly = 1:size(phasors,3) <= split;
        isLate = 1:size(phasors,3) > (size(phasors,3)-split);
        
        handles = doHGPLVPlot(phasors, FW, isEarly, isLate, (1:size(phasors,1))/1000, tx);
        
        figure(handles(1));
        title(['channel ' num2str(compChannel)]);
        
        SaveFig(OUTPUT_DIR, sprintf('%s-plv-ts-%d-%d', subjid, channels(isControl), compChannel), 'png', '-r600');        
        
        figure(handles(2));
        SaveFig(OUTPUT_DIR, sprintf('%s-plv-bar-%d-%d', subjid, channels(isControl), compChannel), 'png', '-r600');        
    end
end
