%% can be run headless with the following variables pre defined
% triggeron
% interest
% fw
% file
% sampRange
% gridStart
% gridOrientation

if (exist('triggeron', 'var') == false)
    triggeron = input('event to trigger on [CUE/finger]: ', 's');
    
    if (strcmp(triggeron, 'finger') ~= 1)
        triggeron = 'cue';
    end
end

if (exist('interest', 'var') == false)
    interest = input('stimulus code of interest [2]: ');
    
    if (isempty(interest) == true)
        interest = 2;
    end
end

if (exist('fw', 'var') == false)
    defaultfw = '3:3:200';
    fw = input(['frequency vector for tfa [' defaultfw ']: '], 's');
    
    if (isempty(fw) == false)
        eval(sprintf('fw = %s;', fw));
    else
        eval(sprintf('fw = %s;', defaultfw));
    end
end

if (exist('file', 'var') == false)
    dirSave = pwd;
    cd(myGetenv('subject_dir'));
    fprintf('select a file: ');
    [file, path] = uigetfile('*.dat','MultiSelect', 'off');
    fprintf('\n');
    file = [path file];
    cd(dirSave);
end

if (exist('gridStart', 'var') == false)
    gridStart = input('position of electrode 1 on grid [LT, lb, rt, rb]: ', 's');
    
    if(isempty(gridStart) == true)
        gridStart = 'LT';
    else
        gridStart = upper(gridStart);
    end
end

if (exist('gridOrientation', 'var') == false)
    gridOrientation = input('orientation of grid counting (Clockwise, cOunterClockwise) [C, o]:', 's');
    
    if(isempty(gridOrientation) == true)
        gridOrientation = 'C';
    else
        gridOrientation = upper(gridOrientation);
    end
end

if (exist('sampRange', 'var') == false)
    dSampRange = '-1200:2400';
    sampRange = input(['range of samples corresponding to an epoch [' dSampRange ']: '], 's');
    
    if (isempty(sampRange) == false)
        eval(sprintf('sampRange = %s;', sampRange));
    else
        eval(sprintf('sampRange = %s;', dSampRange));
    end
end

%% temp
% interest = 2;
% fw = 3:5:200;

% file = ['d:\research\subjects\0dd118\data\d5\maya11_mot_t_h001' '\' 'maya11_mot_t_hS001R02.dat'];
% file = ['d:\research\subjects\ebffea' '\' 'finger_twisterS001R03.dat'];
montageFile = strrep(file, '.dat', '_montage.mat');

[sig, sta, par] = load_bcidat(file);

if (exist(montageFile, 'file') )
    fprintf('montage file exists\n');
    load(montageFile);
else
    fprintf('montage file does not exist\n');
    Montage.BadChannels = [];
end

fs = par.SamplingRate.NumericValue;
sig = double(sig);

if (fs == 1200) % assume gugers
    for c = 1:16:49
        sig(:,c:c+15) = averageReference(sig(:,c:c+15));
    end
else
    sig = averageReference(sig);
end

sig_bp = bandpass(sig, 70, 200, fs, 4);
sig_bp_n = notch(sig_bp, [120 180], fs, 4);
hilb = ((abs(hilbert(sig_bp_n))).^2);

hilb_n = hilb; % just to set the size
for c = 1:64
    hilb_n(:,c) = hilb(:,c)/max(hilb(:,c));
end

if (strcmp(triggeron, 'cue') == 1)
    trig = diff(double(sta.StimulusCode == interest));
    t = sampRange(1)/fs:1/fs:sampRange(end)/fs;
    
    [starts, ends] = getEpochs(sta.StimulusCode, interest);
    starts = starts + sampRange(1);
    
    for c = 1:64
        epoch_data(:,c,:) = ...
            getEpochSignal(sig(:,c), starts, starts + (sampRange(end)-sampRange(1)));
    end
else
    [epoch_data,t,fs,epoch_finger,rt,channel, offsets] = segment_bci2000(...
        sig, sta, par, [sampRange(1) sampRange(end)], 'finger', interest, [0.9*sampRange(1)/fs 0.1*sampRange(1)/fs], 80,...
        'car', [], [3 200]);
    trig = zeros(length(sig), 1);
    trig(offsets) = 1;
end

[av, win] = triggeredAverage(trig, 0.5, 1, hilb_n, -1*sampRange(1), sampRange(end));

figure;

grid_locs = reorderSubplotGrid(gridStart,gridOrientation, [8 8]);    % assume montage?
plot_locs = reshape(1:64, 8, 8)';
    
for c = 1:64
    if(sum(Montage.BadChannels == c) == 0)
        [row, col] = find(grid_locs == c);
        subplot(8, 8, plot_locs(row, col));

        [C,d1,Cxa,d2]=time_frequency_wavelet(squeeze(epoch_data(:,c,:)),fw,fs,1,1,'CPUtest');
        normC=normalize_plv(C',C(t>0.8*t(1) & t<0.2*t(1),:)');

        imagesc(t,fw,normC);
        axis xy;
        set_colormap_threshold(gcf, [-2 2], [-7 7], [1 1 1]);
        hold on;
        temp = smooth(av(:,c),50);
        temp = temp/max(max(av))*fw(end)/2;
        plot(t, temp, 'r', 'LineWidth', 2); hold off;
        hold off;
%     ylim([-0.0 0.3]);
    end
end
