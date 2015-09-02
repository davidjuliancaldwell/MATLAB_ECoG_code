%% this script generates spectra from the rest epochs of 'files' for a
%% subset of electrodes and plots them against each other

%% script to calculate rest spectra
if (~exist('stage','var'))
    stage = 0;
end

if (stage == 0)

%     % for ebffea
%     stim = [38 46];
%     rec = [50 51 58 59];
%     ctl = [60 52 44];
%     subjid = 'ebffea';
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
%     stim = [1 9];
%     rec = 4;
%     ctl = [5 6 7 8 35 36 37];
%     subjid = 'd74850';
%     files = {fullfile(getSubjDir(subjid), 'd4', 'd74850_mot_t001', 'd74850_mot_tS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'd7', 'd74850_mot_t001', 'd74850_mot_tS001R01.dat')};
%     codes = 0;
%     % end d74850
    
%     % for 7ee6bc
%     stim = [47 55];
%     rec = [32 39 40 46 47];
%     ctl = [43 55];
%     subjid = '7ee6bc';
%     files = {fullfile(getSubjDir(subjid), 'D1', 'mara11_finger_twister001', 'mara11_finger_twisterS001R02.dat'), ...
%              fullfile(getSubjDir(subjid), 'D3', 'mara11_finger_twister_guger001', 'mara11_finger_twister_gugerS001R02_clinical.mat')};
%     codes = 1;
%     % end 7ee6bc

    % for 3b787d
    stim = [8];
    rec = [7];
    ctl = [23 24];
    subjid = '3b787d';
    files = {fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R01.dat'), ...
             fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R02.dat'), ...
             fullfile(getSubjDir(subjid), 'data', 'd7', '3b787d_mot_th001', '3b787d_mot_thS001R04.dat')};
    codes = 0;
    % end 3b787d
    
    stage = 1;
end

%% collect data

if (stage == 1)
    % collect all of the windows
    windows = [];
    windowSubCounts = [];

    trodes = union(union(stim, rec), ctl);
    
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
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, double(sig));

        % identify and collect data of interest
        [starts, ends] = getEpochs(ismember(sta.StimulusCode, codes), 1, true);
        
        windows = cat(3, windows, getEpochSignal(sig(:,trodes), starts, ends));
        windowSubCounts = [windowSubCounts; length(starts)];    
    end

    stage = 2;
end

%% do some work

if (stage == 2)
    outdir = fullfile(myGetenv('output_dir'), 'stim');    
    outfile = fullfile(outdir, sprintf('rest-%s.mat', subjid));
    
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
    
    figure;
    
    for chan = 1:size(spectra,2)
        trode = trodes(chan);
        subplot(ceil(size(spectra,2)/2),2,chan);
        
        for sub = 1:length(substarts)
            temp = log(squeeze(spectra(:,chan,substarts(sub):subends(sub))));
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