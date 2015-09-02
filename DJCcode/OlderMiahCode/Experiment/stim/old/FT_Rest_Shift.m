%% This script calculates rest spectra from files, normalizing the spectra
%% from files(2:end) against the spectra from files(1).
%%
%% Additionally, it divides these spectra in to frequency bands (full
%% spectrum, theta, beta, high gamma) and computes shift from the baseline
%% recording session (S1 - pre conditioning) to all subsequent recording
%% sessions.

%% script to calculate rest spectra
if (~exist('stage','var'))
    stage = 0;
end

% stage 0 is setup only
if (stage == 0)

%     % for 3b787d
%     stim = [8];
%     rec = [7];
%     ctl = [23 24];
%     subjid = '3b787d';
%     files = {fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R01.dat'), ...
%              fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R04.dat')};
%     
%     codes = 0;
%     side = 'r';
%     bads = [];
%     
%     % end 3b787d
    
    % for ebffea
    stim = [38 46];
    rec = [50 51 58 59];
    ctl = [60 52 44];
    
    subjid = 'ebffea';
    
    base = fullfile(getSubjDir('ebffea'), 'd7', 'finger_twister001');
    files = {fullfile(base, 'finger_twisterS001R03.dat'), ...
             fullfile(base, 'finger_twisterS001R04.dat'), ...
             fullfile(base, 'finger_twisterS001R05.dat'), ...
             fullfile(base, 'finger_twisterS001R06.dat')};

    codes = 1;    
    side = 'r';
    bads = [38];
    
    % end ebffea
    
%     % for d74850
%     stim = [1 9];
%     rec = 4;
%     ctl = [5 6 7 8 35 36 37];
%     subjid = 'd74850';
%     files = {fullfile(getSubjDir(subjid), 'd4', 'd74850_mot_t001', 'd74850_mot_tS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'd7', 'd74850_mot_t001', 'd74850_mot_tS001R01.dat')};
%     codes = 0;
%     side = 'l';
%     bads = [];
%     % end d74850
%     
    stage = 1;
end

%% collect data

if (stage == 1)
    % collect all of the windows
    windows = [];
    windowSubCounts = [];

    for c = 1:length(files)
        % load data
        [sig, sta, par] = load_bcidat(files{c});
        load(strrep(files{c}, '.dat', '_montage.mat'));
        fs = par.SamplingRate.NumericValue;

        bads = union(bads, Montage.BadChannels);
        
        if (c == 2 && strcmp(subjid, 'ebffea'))
            Montage.BadChannels = union(Montage.BadChannels, 38);
        end
        
        % process data
        sig = sig(:,1:max(cumsum(Montage.Montage)));
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));

        % identify and collect data of interest
        if (isfield(sta, 'StimulusCode'))
            [starts, ends] = getEpochs(ismember(sta.StimulusCode, codes), 1, true);
        else
            [starts, ends] = getEpochs(ismember(sta.TargetCode, codes), 1, true);
        end
        
        windows = cat(3, windows, getEpochSignal(sig, starts, ends));
        windowSubCounts = [windowSubCounts; length(starts)];    
    end

    stage = 2;
end

%% do some work, generate a spectrum for each window grabbed previously

if (stage == 2)
%     outdir = fullfile(myGetenv('output_dir'), 'stim');    
%     outfile = fullfile(outdir, sprintf('rest-%s.mat', subjid));
%     
%     if false%(exist(outfile, 'file'))
%         fprintf('using previously generated cache file\n');
%         load(outfile);
%     else
%         nfft = 128;
        
    [P, f] = pwelch(windows(:,1,1), 1024, 512, 512, fs);

    spectra = zeros(length(P), size(windows,2), size(windows,3));

    h = waitbar(0, 'Calculating spectra');

    for chan = 1:size(windows,2)
        waitbar(chan/size(windows,2), h);
        if (ismember(chan, bads) == false)
            for trial = 1:size(windows,3)
                spectra(:,chan,trial) = ...
                    log(abs(pwelch(windows(:,chan,trial), 1024, 512, 512, fs)));
            end
        end
    end
    close (h); clear h;
    
%     TouchDir(outdir);
%     save(outfile);        
%     end    

    
    stage = 3;
end

%% play with and display the results

colors = 'brgycmk';

if (stage == 3)
    subends = cumsum(windowSubCounts);
    substarts = [1; subends(1:(end-1))+1];
    
    % find pre-conditioning mean spectra
    mupre = squeeze(mean(spectra(:,:,substarts(1):subends(1)),3));
    normspectra = bsxfun(@minus, spectra, mupre);
    
    figure;
    dim = ceil(sqrt(size(spectra,2)));
    
    if(strcmp(subjid,'ebffea'))
        lookup = reshape(rot90(reshape(1:64,8,8)',3)',64,1);
    elseif(strcmp(subjid,'d74850'))
        lookup = 1:62;
    elseif(strcmp(subjid,'3b787d'))
        lookup = 1:64;
    else
        error('not ready for other subjects, must make reshape mtx');
    end
    
    for chan = 1:size(spectra,2)
        if (~ismember(chan, bads))
            subplot(dim,dim,find(lookup==chan));
            
            for sub = 1:length(substarts)
                plotWSE(f(f<200), ...
                    squeeze(normspectra(f<200, chan, substarts(sub):subends(sub))), ...
                    colors(sub), .5, [colors(sub) '-']);
                hold on;
            end
            
            if (ismember(chan, stim))
                tcol = 'r';
            elseif (ismember(chan, rec))
                tcol = 'b';
            else
                tcol = 'k';
            end
            title(num2str(chan), 'Color', tcol);
        end
    end

    for sub = 2:length(substarts)
        figure;
        
        vals = squeeze(mean(normspectra(f<200,:,substarts(sub):subends(sub)), 1));
        hs = ttest(vals');
        
        weights = mean(vals, 2);
        
        bbweights = weights;
        
        weights(bads) = NaN;
        weights(hs == 0) = NaN;
        bbweights(bads) = 0;
        
        PlotDots(subjid, Montage.MontageTokenized, weights, side, [-max(abs(weights)) max(abs(weights))], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        colorbar;
        title(sprintf('Full Spectrum power shift (rel to s1), session: %d', sub));
    end
    
    for sub = 2:length(substarts)
        figure;
        
        vals = squeeze(mean(normspectra(f>70&f<200,:,substarts(sub):subends(sub)), 1));
%         vals = bsxfun(@minus, vals, bbweights);
        
        hs = ttest(vals');
        
        weights = mean(vals, 2);
        weights(bads) = NaN;
        weights(hs == 0) = NaN;
        
        PlotDots(subjid, Montage.MontageTokenized, weights, side, [-max(abs(weights)) max(abs(weights))], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        colorbar;
        title(sprintf('HG power shift (rel to s1), session: %d', sub));
    end

    for sub = 2:length(substarts)
        figure;
        
        vals = squeeze(mean(normspectra(7,:,substarts(sub):subends(sub)), 1));
%         vals = bsxfun(@minus, vals, bbweights);
        hs = ttest(vals');
        
        weights = mean(vals, 2);
        weights(bads) = NaN;
        weights(hs == 0) = NaN;
        
        PlotDots(subjid, Montage.MontageTokenized, weights, side, [-max(abs(weights)) max(abs(weights))], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        colorbar;
        title(sprintf('Beta power shift (rel to s1), session: %d', sub));
    end
    
    for sub = 2:length(substarts)
        figure;
        
        vals = squeeze(mean(normspectra(4,:,substarts(sub):subends(sub)), 1));
%         vals = bsxfun(@minus, vals, bbweights);
        hs = ttest(vals');
        
        weights = mean(vals, 2);
        weights(bads) = NaN;
        weights(hs == 0) = NaN;
        
        PlotDots(subjid, Montage.MontageTokenized, weights, side, [-max(abs(weights)) max(abs(weights))], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        colorbar;
        title(sprintf('Theta power shift (rel to s1), session: %d', sub));
    end    
end