%% script to calculate phase locking values pre/post
if (~exist('stage','var'))
    stage = 0;
end

if (stage == 0)

%     % for ebffea
%     stim = 46;
%     trodes = 1:64;
%     ignore = [1:16 38];
%     
%     subjid = 'ebffea';
%     side = 'r';
%     
%     base = fullfile(getSubjDir('ebffea'), 'd7', 'finger_twister001');
%     files = {fullfile(base, 'finger_twisterS001R03.dat'), ...
%              fullfile(base, 'finger_twisterS001R04.dat'), ...
%              fullfile(base, 'finger_twisterS001R05.dat'), ...
%              fullfile(base, 'finger_twisterS001R06.dat')};
% 
%     codes = 1;    
%     % end ebffea
    
%     % for d74850
%     stim = 1;    
%     trodes = 1:62;
%     ignore = [];
%     
%     subjid = 'd74850';
%     side = 'l';
%     
%     files = {fullfile(getSubjDir(subjid), 'd4', 'd74850_mot_t001', 'd74850_mot_tS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'd7', 'd74850_mot_t001', 'd74850_mot_tS001R01.dat')};
%     codes = 0;
%     % end d74850
    
    % for 7ee6bc _NOT DONE
    stim = [47];
    trodes = 1:64;
    ignore = [];
    side = 'r';
    
    subjid = '7ee6bc';
    files = {fullfile(getSubjDir(subjid), 'D1', 'mara11_finger_twister001', 'mara11_finger_twisterS001R02.dat'), ...
             fullfile(getSubjDir(subjid), 'D3', 'mara11_finger_twister_guger001', 'mara11_finger_twister_gugerS001R02_clinical.mat')};
    codes = 1;
    % end 7ee6bc

%     % for 3b787d
%     stim = 7;
%     trodes = 1:64;
%     ignore = 8;
%     subjid = '3b787d';
%     side = 'r';
%     
%     files = {fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R01.dat'), ...
%              fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R04.dat')};
%     codes = 0;
%     % end 3b787d
    
    stage = 1;
end


%% collect data

if (stage == 1)
    % collect all of the windows
    windows = [];
    windowSubCounts = [];

    for c = 1:length(files)
        % load data
        if (strendswith(files{c}, '.dat'))
            [sig, sta, par] = load_bcidat(files{c});
            load(strrep(files{c}, '.dat', '_montage.mat'));
        elseif (strendswith(files{c}, '.mat'))
            load(files{c});
            load(strrep(files{c}, '.mat', '_montage.mat'));
        else
            error ('unknown file type');
        end
        
        fs = par.SamplingRate.NumericValue;

        % process data
        bads = union(Montage.BadChannels, ignore);
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), ignore, double(sig));
%         sig = BandPassFilter(sig, [12 18], fs, 4);
        
        % identify and collect data of interest
        [starts, ends] = getEpochs(ismember(sta.StimulusCode, codes), 1, true);
        
        newwins = getEpochSignal(sig(:,trodes), starts, ends);
        len = min(nonzeros([size(newwins,1) size(windows, 1)]));
        
        if (size(newwins, 1) > len)
            warning('forcing data truncation - new data');
            newwins = newwins(1:len,:,:);
        elseif (size(windows, 1) > len)
            warning('forcing data truncation - prev data');
            windows = windows(1:len,:,:);
        end  
        
        windows = cat(3, windows, newwins);
        windowSubCounts = [windowSubCounts; length(starts)];    
    end

    stage = 2;
end

%% do some work

if (stage == 2)
    outdir = fullfile(myGetenv('output_dir'), 'stim');    
    outfile = fullfile(outdir, sprintf('coh-%s.mat', subjid));
    
    if exist(outfile, 'file')
        fprintf('using previously generated cache file\n');
        load(outfile);
    else
        nfft = 256;
        [~, f] = mscohere(windows(:,1,1), windows(:,2,1), [], [], nfft, fs);
        
        cohs = zeros(size(windows, 2), length(f), size(windows, 3));
        
        for trial = 1:size(windows, 3)
            trial
            
            for chan = 1:size(windows, 2)
                if (~ismember(chan, bads))
                    cohs(chan,:,trial) = ...
                        mscohere(windows(:,stim,trial), windows(:,chan,trial), [], [], nfft, fs);
                end
            end
        end
        
%         [~,f,nseg] = compute_coherence_multi_channel_phase_bci(windows(:,1,1), nfft, fs);
%         nseg
%         phase_cohs = zeros(size(windows,2), size(windows,2), length(f), size(windows,3)); % CxCxFxN
% 
%         h = waitbar(0, 'Calculating coherence');
% 
%         for trial = 1:size(windows,3)
%             waitbar(trial/size(windows,3), h);
%             trial
%             phase_cohs(:,:,:,trial) = ...
%                 compute_coherence_multi_channel_phase_bci(windows(:,:,trial), nfft, fs);
%         end
%         close (h); clear h;
        TouchDir(outdir);
        save(outfile);        
    end    

    
    stage = 3;
end

%% play with and display the results

locs = trodeLocsFromMontage(subjid, Montage, false);
locs = locs(trodes, :);

if (stage == 3)
    
    idxs = {find(f > 6 & f < 10), find(f > 11 & f < 20), find(f > 70 & f < 110)};
    idxLabels = {'alpha', 'beta', 'high gamma'};

    winStarts = [1; cumsum(windowSubCounts(1:end-1))+1];
    winEnds   = cumsum(windowSubCounts);
    
    overallCohs = zeros(size(cohs, 1), length(winStarts), length(idxs));
    c = 0;
    
    for idx = idxs
        c = c + 1;
        idx = idx{:};
        
        cohForFreqs = squeeze(mean(cohs(:,idx,:), 2));
        cohByRun = zeros(size(cohForFreqs, 1), length(winStarts));
        
        for winIdx = 1:length(winStarts);
            w = winStarts(winIdx):winEnds(winIdx);
            cohByRun(:, winIdx) = mean(cohForFreqs(:, w), 2);
        end
        
        overallCohs(:, :, c) = cohByRun;
    end
    
    % normalize by run 1
    overallCohsNorm = overallCohs ./ repmat(overallCohs(:,1,:), [1 size(overallCohs, 2) 1]);
    
    % visualize
    v = overallCohsNorm(~isnan(overallCohsNorm));
    clims = [1-max(abs(v-1)) 1+max(abs(v-1))];
    
    for c = 1:length(idxs) % this gets us the frequency bands of interest
        idx = idxs{c};
        idxLabel = idxLabels{c};
        freqs = f(idx);
        
        for winIdx = 2:length(winStarts) % this gets us the time periods of interest, we could start this at 2 to ignore the pre-conditioning case
            figure;
            PlotDotsDirect(subjid, locs, overallCohsNorm(:,winIdx,c), side, clims, 15, 'recon_colormap');
            title(sprintf('normalized coherence - run %d - %s (%d \\leq f \\leq %d)', winIdx, idxLabels{c}, round(min(freqs)), round(max(freqs))));
            load('recon_colormap');
            colormap(cm);
            colorbar;
%             maximize;
%             view(92,18);
            
            figname = sprintf('%s-%s-R%d.png', subjid, idxLabels{c}, winIdx);
            SaveFig(outdir, figname, 'png');
            close;
        end
    end    
end