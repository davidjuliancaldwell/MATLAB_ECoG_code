%% constants
SIDS = {'30052b', 'fc9643'};
SCODES = {'S1', 'S2'};

OUTPUT_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'figures');
META_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'meta');

TouchDir(OUTPUT_DIR);
TouchDir(META_DIR);

FW = 1:3:200;

%% brains

for sIdx = 1:length(SIDS)
	subjid = SIDS{sIdx};
	load(fullfile(META_DIR, sprintf('%s-data.mat', subjid)));
    figure
    [~, hemi, ~, cChan] = interactionDataFiles(subjid);
    PlotCortex(subjid, hemi);
    PlotElectrodes(subjid, {'Grid(1:64)'});
%     plot3(Montage.MontageTrodes(cChan,1)+1, Montage.MontageTrodes(cChan,2), Montage.MontageTrodes(cChan,3), 'ko', 'markersize', 20, 'linewidth',3);
%     
%     for chan = channels(2:end)
%         plot3(Montage.MontageTrodes(chan,1), Montage.MontageTrodes(chan,2), Montage.MontageTrodes(chan,3), 'go', 'markersize', 20, 'linewidth', 3);
%     end

    if (sIdx == 1)
        camroll(18);
        zoom(1.1);
    end
    
    SaveFig(OUTPUT_DIR, sprintf('brain-%s', subjid), 'png', '-r600');
    close
end