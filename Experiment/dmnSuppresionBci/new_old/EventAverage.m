function [rs, outputFilepath] = EventAverage(ds)
% bci dmn analysis    
    rs.aggregate.trodeStatus = [];
    rs.aggregate.epochs = [];
    rs.aggregate.targets = [];
    rs.aggregate.results = [];

    rs.aggregate.restStart = -1;
    rs.aggregate.restEnd = -1;
    rs.aggregate.fbStart = -1;
    rs.aggregate.fbEnd = -1;
    rs.aggregate.fs = -1;
    
    for recNum = 1:length(ds.recs)
        fprintf('processing recording %d of %d\n', recNum, length(ds.recs));
        
        rs.results(recNum) = processRecording(ds.recs(recNum));
        
        if (isempty(rs.aggregate.trodeStatus))
            rs.aggregate.trodeStatus = rs.results(recNum).trodeStatus;
        else
            rs.aggregate.trodeStatus = rs.aggregate.trodeStatus & rs.results(recNum).trodeStatus;
        end
        
        rs.aggregate.epochs  = cat(3, rs.aggregate.epochs, rs.results(recNum).epochs);
        rs.aggregate.targets = cat(1, rs.aggregate.targets, rs.results(recNum).targets);
        rs.aggregate.results = cat(1, rs.aggregate.results, rs.results(recNum).results);
        
        rs.aggregate.trodeLabels = rs.results(recNum).trodeLabels; % assuming constant from rec to rec
        rs.aggregate.restStart   = rs.results(recNum).restStart;   % assuming constant from rec to rec
        rs.aggregate.restEnd     = rs.results(recNum).restEnd;     % assuming constant from rec to rec
        rs.aggregate.fbStart     = rs.results(recNum).fbStart;     % assuming constant from rec to rec
        rs.aggregate.fbEnd       = rs.results(recNum).fbEnd;       % assuming constant from rec to rec
        rs.aggregate.fs          = rs.results(recNum).fs;          % assuming constant from rec to rec
    end

    outputFilename = ['EventAverage_' ds.subjId '_' ds.type '_rs'];
    outputDir = myGetenv('output_dir');
    outputFilepath = [outputDir '\' outputFilename];
    fprintf('saving output to %s\n', outputFilepath);
    save(outputFilepath, 'rs', 'ds');
    
end

function result = processRecording(rec)

    bad.epochs = [];
    bad.fs = 0;
    
    path = [rec.dir '\' rec.file];
    mpath = [rec.dir '\' rec.montage];
    if (isfield(rec, 'badepochs'))
        epath = [rec.dir '\' rec.badepochs];
    else
        epath = [];
    end
    
    switch(rec.type)
        case 'bci2k'
            [sig, sta, par] = load_bcidat(path);
            load(mpath);        
            
            if (~isempty(epath))
                load(epath);
            else
                badFeedbackEpochs = [];
                badRestEpochs = [];
            end
            
            signals = double(sig);
            
            fs = par.SamplingRate.NumericValue;
            
            targetCode = sta.TargetCode;
            resultCode = sta.ResultCode;
            feedback   = sta.Feedback;
            
            gugers = isfield(par,'CommonReference');
             
        case 'clinical'
            load(path);
            load(mpath);
            if (~isempty(epath))
                load(epath);
            else
                badFeedbackEpochs = [];
                badRestEpochs = [];                
            end
            
            gugers = false;
            
        otherwise
            warning('unknown filetype of %s entered, should be bci2k', rec.type);
            result = bad;
    end

    if (gugers)
        fprintf('put this back!!\n');
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end
    
    signals = signals(:,rec.trodes);
    signals = notch(signals, [60 120 180], fs, 4);
    hamp = hilbAmp(signals, [70 200], fs);
%     score = zscore(hamp);
% fprintf('put this back!!\n');
%     score = hamp;
    score = zscoreAgainstInterest(hamp, targetCode, 0);
%     hpwr = hamp.^2;

    smoothTime = 0.5;
    smoothed = zeros(size(score));
    
    parfor trode = 1:size(score,2)
        smoothed(:,trode) = smooth(score(:,trode), smoothTime*fs);
    end

%     smoothHamp = hamp;
    
    [trialStarts, trialEnds] = getEpochs(targetCode > 0, 1);
    trialStarts = trialStarts - fs; % include a second before for rest epoch
    trialStarts = max(trialStarts, 1); % get rid of anything that starts before t = 0
 
    trialStarts(badFeedbackEpochs) = [];
    trialEnds  (badFeedbackEpochs) = [];
    
    % eliminate trials of differing length
    idxs = trialStarts - trialEnds ~= mode(trialStarts - trialEnds);
    trialStarts(idxs) = [];
    trialEnds(idxs) = [];

    result.epochs = getEpochSignal(smoothed, trialStarts, trialEnds);
    result.targets = targetCode(trialEnds - 1);
    result.results = resultCode(trialEnds - 1);
    
    result.restStart = 1/fs;
    result.restEnd = 1;
    
    feedbackEpoch = squeeze(getEpochSignal(double(feedback), trialStarts(1), trialEnds(1)));
    fbVals = diff(double(feedbackEpoch ~= 0));
    result.fbStart = find(fbVals == 1) / fs;
    result.fbEnd   = find(fbVals == -1) / fs;
    
    result.fs = fs;
    
    badChannelFlag = zeros(sum(Montage.Montage),1);
    badChannelFlag(Montage.BadChannels) = 1;
    
    result.trodeStatus = ~badChannelFlag(rec.trodes);
    
    result.trodeLabels = getLabelsFromMontage(Montage, rec.trodes);    
end