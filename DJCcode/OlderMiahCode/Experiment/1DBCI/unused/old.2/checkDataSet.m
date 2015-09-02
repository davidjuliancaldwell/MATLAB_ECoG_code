function retVal = checkDataSet(filename)
    if(~exist(filename, 'file'))
        warning('file: %s, did not exist, checkDataSet failed', filename);
        retVal = false; return;
    end
    
    % clean file contents
    [signals, states, parameters] = load_bcidat(filename);
    parameters = CleanBCI2000ParamStruct(parameters);
    signals = double(signals);
    
    % remove offset in signals
    msig = mean(signals);
    signals = signals - repmat(msig, size(signals,1), 1);
    
    % check for montage
    montageFilenameAttempt = strrep(filename, '.dat', '_montage.mat');
    
    if (exist(montageFilenameAttempt, 'file'))
        load(montageFilenameAttempt);
    end
    
    figure;
    ax1 = subplot(121);
    plotSignals(ax1, [signals double(states.Feedback) double(states.TargetCode) double(states.ResultCode)], parameters.SamplingRate);
    
    ax2 = subplot(122);
    plotSpectra(ax2, signals, parameters.SamplingRate);
    
    if (~isempty(Montage.BadChannels))
        badChanStr = num2str(Montage.BadChannels(1));
        
        for c = 2:length(Montage.BadChannels)
            badChanStr = [badChanStr ' ' num2str(Montage.BadChannels(c))];
        end    
    else
        badChanStr = 'none';
    end
    
    mtit(sprintf('%s : badChannels %s', filename, badChanStr), ...
        'xoff', 0, 'yoff', 0.05);
    
    retVal = 1;
end

function plotSignals(handle, signals, fs)
    normalizers = max(abs(signals));
    signals = signals ./ repmat(normalizers, size(signals,1), 1);
    adder = 0:(size(signals,2)-1);
    signals = signals + repmat(adder, size(signals,1), 1);
    
    t = (0:(size(signals,1)-1)) / fs;
    
    plot(handle, t, signals);    
end

function plotSpectra(handle, signals, fs)
    for c = 1:size(signals,2)
        [f(:,c), hz] = pwelch(signals(:,c), fs, fs/2, fs/2, fs);
    end    
    plot(handle, hz, log(f));
end