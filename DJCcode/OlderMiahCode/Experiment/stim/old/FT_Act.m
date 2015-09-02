%% script to calculate rest spectra
if (~exist('stage','var'))
    stage = 0;
end

if (stage == 0)
    
%     % for ebffea
%     stim = [38 46];
%     rec = [50 51 58];
%     ctl = [60 52 44];
%     subjid = 'ebffea';
%     
%     base = fullfile(getSubjDir('ebffea'), 'd7', 'finger_twister001');
%     files = {fullfile(base, 'finger_twisterS001R03.dat'), ...
%              fullfile(base, 'finger_twisterS001R04.dat'), ...
%              fullfile(base, 'finger_twisterS001R05.dat'), ...
%              fullfile(base, 'finger_twisterS001R06.dat')};
% 
%     codes = 2:3;    
%     rests = 1;
%     % end ebffea
    
    % for d74850
    stim = [1 9];
    rec = 4;
    ctl = [5 6 7 8 35 36 37];
    subjid = 'd74850';
    files = {fullfile(getSubjDir(subjid), 'd4', 'd74850_mot_t001', 'd74850_mot_tS001R02.dat'), ...
             fullfile(getSubjDir(subjid), 'd7', 'd74850_mot_t001', 'd74850_mot_tS001R01.dat')};
    rests = 0;
    codes = 1;
    % end d74850
    
    stage = 1;
end

%% collect data

if (stage == 1)
    % collect all of the windows
    windows = [];
    rwindows = [];
    
    windowSubCounts = [];
    rwindowSubCounts = [];
    
    trodes = union(union(stim, rec), ctl);
    
    for c = 1:length(files)
        % load data
        [sig, sta, par] = load_bcidat(files{c});
        load(strrep(files{c}, '.dat', '_montage.mat'));
        fs = par.SamplingRate.NumericValue;

        % process data
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));

        % identify and collect data of interest
        [starts, ends] = getEpochs(ismember(sta.StimulusCode, codes), 1, true);
        
        windows = cat(3, windows, getEpochSignal(sig(:,trodes), starts, ends));
        windowSubCounts = [windowSubCounts; length(starts)];    
        
        [starts, ends] = getEpochs(ismember(sta.StimulusCode, rests), 1, true);
        
        rwindows = cat(3, rwindows, getEpochSignal(sig(:,trodes), starts, ends));
        rwindowSubCounts = [rwindowSubCounts; length(starts)];
    end

    stage = 2;
end

%% do some work

if (stage == 2)
    outdir = fullfile(myGetenv('output_dir'), 'stim');    
    outfile = fullfile(outdir, sprintf('act-%s.mat', subjid));
    
    if false%(exist(outfile, 'file'))
        fprintf('using previously generated cache file\n');
        load(outfile);
    else
%         nfft = 128;
        
        [P, f] = pwelch(windows(:,1,1), 512, 256, 256, fs);
        
        spectra = zeros(length(P), size(windows,2), size(windows,3));

        h = waitbar(0, 'Calculating spectra');

        for chan = 1:size(windows,2)
            waitbar(chan/size(windows,2), h);
            for trial = 1:size(windows,3)
                spectra(:,chan,trial) = ...
                    pwelch(windows(:,chan,trial), 512, 256, 256, fs);
            end
        end
        
        [P, f] = pwelch(rwindows(:,1,1), 512, 256, 256, fs);
        
        rspectra = zeros(length(P), size(windows,2), size(windows,3));

        waitbar(0, h, 'Calculating spectra');

        for chan = 1:size(rwindows,2)
            waitbar(chan/size(rwindows,2), h);
            for trial = 1:size(rwindows,3)
                rspectra(:,chan,trial) = ...
                    pwelch(rwindows(:,chan,trial), 512, 256, 256, fs);
            end
        end
        
        close (h); clear h;
        TouchDir(outdir);
        save(outfile);        
    end    

    
    stage = 3;
end

%% play with and display the results

colors = 'brgycmk';

if (stage == 3)
    subends = cumsum(windowSubCounts);
    substarts = [1; subends(1:(end-1))+1];
    
    subrends = cumsum(rwindowSubCounts);
    subrstarts = [1; subrends(1:(end-1))+1];
    
    figure;
    
    for chan = 1:size(spectra,2)
        trode = trodes(chan);
        subplot(ceil(size(spectra,2)/2),2,chan);
        
        for sub = 1:length(substarts)
            temp = log(squeeze(spectra(:,chan,substarts(sub):subends(sub))));
            rmean = log(mean(squeeze(rspectra(:,chan,subrstarts(sub):subrends(sub))),2));
            
            temp = bsxfun(@minus, temp, rmean);
            
            plotWSE(f(f<200),temp(f<200,:),colors(sub),.5,[colors(sub) '-']);
%             plot(f(f<200), temp(f<200), colors(sub));
            hold on;
        end
        if(ismember(trode, stim))
            title(sprintf('\\color{red}%d',trode));
        elseif(ismember(trode, rec))
            title(sprintf('\\color{blue}%d',trode));
        else
            title(sprintf('\\color{black}%d',trode));
        end
    end
end