function [restScores, tgtScores, fbScores, rewardScores, epochTargetCodes] = ProcessBCI2000Recording(directory, recname, montagename)
    %% setup

%     directory = 'd:\research\subjects\30052b\d3\30052b_ud_mot_t001\';
%     recname = '30052b_ud_mot_tS001R01.dat';
%     montagename = '30052b_ud_mot_tS001R01_montage.mat';


    %% build vars
    recpath = [directory '\' recname];
    montagepath = [directory '\' montagename];
    outfilename = [recname '.mat'];
    outfilepath = ['cache\' outfilename];

    %% process
    fprintf('processing bci2k recording: %s\n', recpath);

    % read in bci2k file
    fprintf('  loading file\n');
    [signals, states, parameters] = load_bcidat(recpath);
    signals = double(signals);
    parameters = CleanBCI2000ParamStruct(parameters);
    load(montagepath);
    fs = parameters.SamplingRate;

    % average reference
    fprintf('  common average referencing ...');

    if (mod(fs, 500) == 0)
        fprintf(' neuroscans detected.\n');
        signalsCar = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    else
        fprintf(' gugers detected.\n');
        signalsCar = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    end

    % notch filter
    fprintf('  notch filtering.\n')
    notchFreqs = [60 120 180];
    signalsNotch = NotchFilter(signalsCar, notchFreqs, fs);

    % bandpass
    fprintf('  bandpass filtering.\n')
    bandpassFreqs = [70 200];
    bandpassOrder = 6;
    signalsBp = BandPassFilter(signalsNotch, bandpassFreqs, fs, bandpassOrder);

    % hilb amp
    fprintf('  taking the hilbert amplitude, power, and log power.\n')
    signalsHilbAmp = abs(hilbert(signalsBp));

    % hilb pwr
    signalsHilbPwr = signalsHilbAmp .^2;

    % log hilb pwr
    signalsLogHilbPwr = log(signalsHilbPwr);

    % smoothed log hilb pwr
    fprintf('  smoothing log hilbert power.\n');
    smoothingWindowWidth = fs/2;
    signalsSmoothed = GaussianSmooth(signalsLogHilbPwr, smoothingWindowWidth);
    signalsExpSmoothed = exp(signalsSmoothed);

    % scores of mean values during rest, targeting, feedback, reward
    fprintf('  processing in epochs and z-scores\n');
    [restStarts, restEnds] = getEpochs(states.TargetCode, 0);
    [tgtStarts, tgtEnds] = getEpochs(states.TargetCode ~= 0 & states.Feedback == 0 & states.ResultCode == 0, 1);
    [fbStarts, fbEnds] = getEpochs(states.Feedback ~= 0, 1);
    [rewardStarts, rewardEnds] = getEpochs(states.ResultCode ~= 0, 1);

    epochTargetCodes = states.TargetCode(fbStarts);
    up = 1;
    down = 2;

    restMeans = zeros(min(length(restStarts), length(restEnds)), size(signals,2));

    for c = 1:size(restMeans, 1)
        restMeans(c,:) = mean(signalsHilbPwr(restStarts(c):restEnds(c),:),1); 
    end

    tgtMeans = zeros(min(length(tgtStarts), length(tgtEnds)), size(signals,2));

    for c = 1:size(tgtMeans, 1)
        tgtMeans(c,:) = mean(signalsHilbPwr(tgtStarts(c):tgtEnds(c),:),1); 
    end

    fbMeans = zeros(min(length(fbStarts), length(fbEnds)), size(signals,2));

    for c = 1:size(fbMeans, 1)
        fbMeans(c,:) = mean(signalsHilbPwr(fbStarts(c):fbEnds(c),:),1); 
    end

    rewardMeans = zeros(min(length(rewardStarts), length(rewardEnds)), size(signals,2));

    for c = 1:size(rewardMeans, 1)
        rewardMeans(c,:) = mean(signalsHilbPwr(rewardStarts(c):rewardEnds(c),:),1); 
    end

    restScores = (restMeans - repmat(mean(restMeans,1), size(restMeans, 1), 1)) ... 
        ./ repmat(std(restMeans, 1), size(restMeans, 1), 1);

    tgtScores = (tgtMeans - repmat(mean(restMeans,1), size(tgtMeans, 1), 1)) ...
        ./ repmat(std(restMeans, 1), size(tgtMeans, 1), 1);

    fbScores = (fbMeans - repmat(mean(restMeans,1), size(fbMeans, 1), 1)) ...
        ./ repmat(std(restMeans, 1), size(fbMeans, 1), 1);

    rewardScores = (rewardMeans - repmat(mean(restMeans,1), size(rewardMeans, 1), 1)) ...
        ./ repmat(std(restMeans, 1), size(rewardMeans, 1), 1);


    clear c;
    % save(outfilepath);
end