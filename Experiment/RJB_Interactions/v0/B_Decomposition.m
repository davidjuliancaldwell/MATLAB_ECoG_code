%% constants
SIDS = {'30052b', 'fc9643'};
SCODES = {'S1', 'S2'};

OUTPUT_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'figures');
META_DIR = fullfile(myGetenv('output_dir'), '1DBCI_Interaction', 'meta');

TouchDir(OUTPUT_DIR);
TouchDir(META_DIR);

FW = 1:3:200;

%% do TFA decomposition for all electrodes, save the results and make plots
for sIdx = 1:length(SIDS)
	subjid = SIDS{sIdx};
	load(fullfile(META_DIR, sprintf('%s-data.mat', subjid)));	
	
	normalizationMask = zeros(size(t)) == 1;
	normalizationMask(t > (tx.iti+.2) & t < (tx.pre)) = 1;
    
    for chanIdx = 1:length(channels)
		[~, ~, win, ~] = time_frequency_wavelet(squeeze(data(:,chanIdx,:)), FW, fs, 1, 1, 'CPUtest');        
		
        % up targets
        subplot(211);
        C = mean(abs(win(:,:,targets==1)),3);        
        normC=normalize_plv(C',C(normalizationMask,:)');            
		imagesc(t,FW,normC);
		axis xy;
		set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);        
		title([trodeNameFromMontage(channels(chanIdx),Montage) '- up']);             
		vline([tx.pre tx.fb tx.post]);
		xlabel('time (s)');
        ylabel('frequency (hz)');
        
        subplot(212);
        C = mean(abs(win(:,:,targets==2)),3);        
        normC=normalize_plv(C',C(normalizationMask,:)');            
		imagesc(t,FW,normC);
		axis xy;
		set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);        
		title([trodeNameFromMontage(channels(chanIdx),Montage) '- down']);             
		vline([tx.pre tx.fb tx.post]);
		xlabel('time (s)');
        ylabel('frequency (hz)');
        
		SaveFig(OUTPUT_DIR, sprintf('%s-tfa-%d', subjid, channels(chanIdx)), 'png', '-r600');
        save(fullfile(META_DIR, sprintf('%s-decomp-%d.mat', subjid, channels(chanIdx))), 'win', 'FW');        
    end    
end
