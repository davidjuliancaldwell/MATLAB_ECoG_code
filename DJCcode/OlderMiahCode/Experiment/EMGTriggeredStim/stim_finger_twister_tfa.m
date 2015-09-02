%% to run headless, this program needs the following variables to be
%% predefined

% filename - name of data file to analyze
% path - path with trailing slash containing filename
% check_glove - boolean determining whether or not to plot dg traces for
%   the epochs
% epoch_mode - string determining how the epochs will be separated
%   ('finger' or 'cue')
% save_figs - boolean determining whether or not to save figures
% fig_dir - directory to store generated figures

%% get necessary inputs
if(~exist('run_count','var'))
    run_count = 0;
end
run_count = run_count + 1;

fprintf('getting necessary inputs...\n');

if (~exist('check_glove', 'var'))
    check_glove_str = input('check glove [y/N]: ', 's');

    if (strcmp(check_glove_str, 'y') == 1)
        check_glove = true;
    else
        check_glove = false;
    end
end

if (~exist('save_figs', 'var'))
    save_figs_str = input('save figures [y/N]: ', 's');
    
    if (strcmp(save_figs_str, 'y') == 1)
        save_figs = true;
    else
        save_figs = false;
    end
end

if (save_figs == true && ~exist('fig_dir', 'var'))
    fig_dir = uigetdir(pwd);
end

if (~exist('epoch_mode', 'var'))
    epoch_mode = input('divide epochs by finger or cue [FINGER/cue]: ', 's');
    
    if (strcmp(epoch_mode, 'cue') ~= 1)
        epoch_mode = 'finger';
    end
end

if (~exist('stim_trodes', 'var'))
    stim_trodes = [];
end

if (~exist('activity_trodes', 'var'))
    activity_trodes = [];
end

%% select file
fprintf('selecting and opening the file to analyze...\n');

if(~exist('filename','var') || ~exist('path','var'))
    curdir = pwd;

    datadir = myGetenv('subject_dir');
    cd(datadir);

    [filename, path] = uigetfile('*.dat;*.mat','MultiSelect', 'off');

    cd (curdir);
end

filepath = [path filename];

if (strendswith(filepath, '.dat'))
    [sig, sta, par] = load_bcidat(filepath);
    pext_loc = strfind(filepath, '.dat');
    fext_loc = strfind(filename, '.dat');
else
    load(filepath);    
    pext_loc = strfind(filepath, '.mat');
    fext_loc = strfind(filename, '.mat');
end

filename_stripped = filename(1:fext_loc-1);
filepath_stripped = filepath(1:pext_loc-1);

load ([filepath_stripped '_montage.mat']);


%% analyze
fprintf('analyzing...\n');

fs = par.SamplingRate.NumericValue;

sig = double(sig);

if (fs == 1200) % assume gugers
    for c = 1:16:49
        sig(:,c:c+15) = averageReference(sig(:,c:c+15));
    end
else
    sig = averageReference(sig);
end

codes = [2 3];
codes_str = {'thumb', 'index', 'all'};

for code_ctr = 1:length(codes)+1
    fprintf('segmenting data (%s)...\n', codes_str{code_ctr});
    
    if (code_ctr > length(codes))
        [epoch_data,t,fs,epoch_finger,rt,channel] = segment_bci2000(...
            sig, sta, par, [-1.0*fs 2*fs], epoch_mode, codes, [-0.9 -0.50], 80,...
            'car', Montage.BadChannels, [3 200]);        
%         [epoch_data,t,fs,epoch_finger,rt,channel] = segment_bci2000(...
%             sig, sta, par, [-1.0*fs 2*fs], epoch_mode, codes, [-1.25 -0.75], 80,...
%             'car', Montage.BadChannels, [3 200]);        
    else
        [epoch_data,t,fs,epoch_finger,rt,channel] = segment_bci2000(...
            sig, sta, par, [-1.0*fs 2*fs], epoch_mode, codes(code_ctr), [-0.9 -0.50], 80,...
            'car', Montage.BadChannels, [3 200]);
    end

    if (check_glove == true)
        figure;

        figdim = ceil(sqrt(size(epoch_finger,3)));
        epoch_count = size(epoch_finger,3);

        for c = 1:epoch_count
            subplot(figdim, figdim, c);
            plot(t, squeeze(epoch_finger(:,:,c)));
            title(sprintf('epoch %i, finger %i', c, channel(c)));
        end

        if(save_figs)
            maximize(gcf);
        end
        
        mtit(sprintf('%s\_dg\_%s', filename_stripped, codes_str{code_ctr}), 'xoff', 0, 'yoff', 0.06);
        
        if(save_figs)
            dg_filename = sprintf('%s_dg_%s', filename_stripped, codes_str{code_ctr});
            SaveFig(fig_dir, dg_filename);
        end
    end
        
    %% do TFA and visualize
    fprintf('performing tfa (%s)...\n', codes_str{code_ctr});
    
    fw = 3:3:200;

    % this section depends on the montage - TODO write a function that figures
    % this out
    grid_locs = reorderSubplotGrid('LB','C', [8 8]);    
    plot_locs = reshape(1:64, 8, 8)';
    % end

    figure;
    trodes = 1:Montage.Montage;

    for c = trodes
        if (sum(Montage.BadChannels == c) == 0)
            [row, col] = find(grid_locs == c);
            subplot(8, 8, plot_locs(row, col));

            [C,d1,Cxa,d2]=time_frequency_wavelet(squeeze(epoch_data(:,c,:)),fw,fs,1,1,'CPUtest');
            normC=normalize_plv(C',C(t>-1 & t<-.5,:)');

            imagesc(t,fw,normC);
            axis xy;
            set_colormap_threshold(gcf, [-2 2], [-7 7], [1 1 1]);
            
            if (sum(stim_trodes == c) > 0)
                title(sprintf('electrode %i', c), 'Color', 'r', 'FontWeight', 'bold');
            elseif (sum(activity_trodes == c) > 0)
                title(sprintf('electrode %i', c), 'Color', 'b', 'FontWeight', 'bold');
            else
                title(sprintf('electrode %i', c));
            end
            
            section = normC(fw > 70 & fw < 200, :);
            section_av = sum(section,1)/size(section,1);
            
            ignore = floor(length(section_av)*0.05);
            section_av(1:ignore) = mean(section_av);
            section_av(end-ignore:end) = mean(section_av);
            
            [section_max, section_loc] = max(section_av);
            
%             figure, plot(section_av);
%             hold on;
%             plot(section_loc, section_max, 'rx');
            
            mags(code_ctr,c,run_count) = section_max;
            delays(code_ctr,c,run_count) = section_loc - find(t == 0);
            
        end
    end
    
    if (save_figs)
        maximize(gcf);
    end
    
    mtit(sprintf('%s\_tfa\_%s', strrep(filename_stripped, '_', '\_'), codes_str{code_ctr}), 'xoff', 0, 'yoff', 0.08);

    if(save_figs)
        tfa_filename = sprintf('%s_tfa_%s', filename_stripped, codes_str{code_ctr});
        SaveFig(fig_dir, tfa_filename);
    end
    
end    

fprintf('script complete.\n\n\n');