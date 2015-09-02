function [rs, outputFilepath] = TargetingShift(ds)
% bci dmn analysis    
    rs.aggregate.trodeStatus = [];
    rs.aggregate.epochs = [];
    rs.aggregate.targets = [];
    rs.aggregate.results = [];

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
        rs.aggregate.fs          = rs.results(recNum).fs;          % assuming constant from rec to rec
    end

    outputFilename = ['TargetingShift_' ds.subjId '_' ds.type '_rs'];
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
    
    switch(rec.type)
        case 'bci2k'
            [sig, sta, par] = load_bcidat(path);
            load(mpath);        
            
            signals = double(sig);
            
            fs = par.SamplingRate.NumericValue;
            
            targetCode = sta.TargetCode;
            resultCode = sta.ResultCode;
            feedback   = sta.Feedback;
            
            gugers = isfield(par,'CommonReference');
             
        case 'clinical'
            load(path);
            load(mpath);
            
            gugers = false;
            
        otherwise
            warning('unknown filetype of %s entered, should be bci2k', rec.type);
            result = bad;
    end

    if (gugers)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end
    
    signals = signals(:,rec.trodes);
    signals = notch(signals, [60 120 180], fs, 4);
    hamp = hilbAmp(signals, [70 200], fs);
    score = zscoreAgainstInterest(hamp, targetCode, 0);

    [starts, ends] = getEpochs(targetCode > 0 & feedback == 0 & resultCode == 0, 1);
    
    % eliminate trials of differing length
    idxs = starts - ends ~= mode(starts - ends);
    starts(idxs) = [];
    ends(idxs) = [];

    result.epochs = getEpochSignal(score, starts, ends);
    result.targets = targetCode(ends - 1);
    result.results = resultCode(ends - 1);
        
    result.fs = fs;
    
    badChannelFlag = zeros(sum(Montage.Montage),1);
    badChannelFlag(Montage.BadChannels) = 1;
    
    result.trodeStatus = ~badChannelFlag(rec.trodes);
    
    result.trodeLabels = getLabelsFromMontage(Montage, rec.trodes);    
end