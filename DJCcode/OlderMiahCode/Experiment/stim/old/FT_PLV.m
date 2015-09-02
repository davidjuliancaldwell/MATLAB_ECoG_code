%% script to calculate phase locking values pre/post
if (~exist('stage','var'))
    stage = 0;
end

if (stage == 0)
    
    % for ebffea
    stim = [38 46];
    comp = [50 51 58];
    control = [35 36];
    subjid = 'ebffea';
    
    base = fullfile(getSubjDir('ebffea'), 'd7', 'finger_twister001');
    files = {fullfile(base, 'finger_twisterS001R03.dat'), ...
             fullfile(base, 'finger_twisterS001R04.dat'), ...
             fullfile(base, 'finger_twisterS001R05.dat'), ...
             fullfile(base, 'finger_twisterS001R06.dat')};

    codes = 2:3;
    useGlove = true;
    presamps = -100;
    postsamps = 1500;
    
    % end ebffea
    
%     % for d74850
%     stim = [1 9];
%     comp = 4;
%     control = 8;
%     subjid = 'd74850';
%     files = {fullfile(getSubjDir(subjid), 'd4', 'd74850_mot_t001', 'd74850_mot_tS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'd7', 'd74850_mot_t001', 'd74850_mot_tS001R01.dat')};
%     codes = 1;
%     useGlove = false;
%     presamps = 600;
%     postsamps = 2400;
%     
%     % end d74850
    
    stage = 1;
end

%% collect data

if (stage == 1)
    % collect all of the windows
    windows = [];
    windowSubCounts = [];

    trodes = union(union(stim, comp), control);
    
    for c = 1:length(files)
        % load data
        [sig, sta, par] = load_bcidat(files{c});
        load(strrep(files{c}, '.dat', '_montage.mat'));
        fs = par.SamplingRate.NumericValue;

        % process data
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));

        % identify and collect data of interest
        if (useGlove)
            [off, ch] = identifyGloveMotion(sta, par, 22, par.SamplingRate.NumericValue, [0 fs], [fs/2 0], codes, 'onset', 0.2);
        else
            off = getEpochs(ismember(sta.StimulusCode, codes), 1);
        end

        starts = off+presamps;
        ends = off+postsamps;

%         esig = getEpochSignal(sig(:,trodes), starts, ends);
%         esig = esig + repmat(100*sin(20*pi*((1:size(esig,1))'/fs)), [1 size(esig, 2) size(esig,3)]);
%         windows = cat(3, windows, esig);
        windows = cat(3, windows, getEpochSignal(sig(:,trodes), starts, ends));
        windowSubCounts = [windowSubCounts; length(starts)];    
    end

    stage = 2;
end

%% do some work

if (stage == 2)
    outdir = fullfile(myGetenv('output_dir'), 'stim');    
    outfile = fullfile(outdir, sprintf('coh-%s.mat', subjid));
    
    if false%(exist(outfile, 'file'))
        fprintf('using previously generated cache file\n');
        load(outfile);
    else
        nfft = 128;
        [~,f,nseg] = compute_coherence_multi_channel_phase_bci(windows(:,1,1), nfft, fs);
        nseg
        phase_cohs = zeros(size(windows,2), size(windows,2), length(f), size(windows,3)); % CxCxFxN

        h = waitbar(0, 'Calculating coherence');

        for trial = 1:size(windows,3)
            waitbar(trial/size(windows,3), h);
            trial
            phase_cohs(:,:,:,trial) = ...
                compute_coherence_multi_channel_phase_bci(windows(:,:,trial), nfft, fs);
        end
        close (h); clear h;
        TouchDir(outdir);
        save(outfile);        
    end    

    
    stage = 3;
end

%% play with and display the results

if (stage == 3)
    % phase_cohs is CxCxFxN
    for compTrode = comp
        compIdx = find(trodes==compTrode);
        
        figure;
        
        for stimTrode = [stim control]
            stimIdx = find(trodes==stimTrode);
            
            fprintf('comparing %d to %d\n', compTrode, stimTrode);
            
            subplot(1, length([stim control]), find([stim control] == stimTrode));

            % develop actual plot here
            temp = squeeze(abs(phase_cohs(compIdx, stimIdx, f <= 200, :)))';

            fwidth = max(1,floor(size(temp)/10));
            sigmas = max(1,floor(fwidth/3));        
            
%             toplot = GaussianSmooth2(temp, fwidth, sigmas);
            toplot = GaussianSmooth2(bsxfun(@rdivide, temp, mean(temp, 1)), fwidth, sigmas);
            
            imagesc(f(f <= 200), 1:size(temp,1), toplot);
            xlabel('frequency (Hz)');
            ylabel('trial');
%             set(gca, 'CLim', [0 1]);
            colorbar;
            
            if (ismember(stimTrode, stim))
                title(sprintf('\\color{red}%d\\color{blue}-%d', compTrode, stimTrode));
            else
                title(sprintf('\\color{red}%d\\color{black}-%d', compTrode, stimTrode));
            end
            
        end
    end    
end