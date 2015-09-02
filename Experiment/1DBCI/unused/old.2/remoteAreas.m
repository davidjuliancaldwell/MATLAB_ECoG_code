function [rs, outputFilepath] = remoteAreas(ds)

    rs.epochs = [];
    rs.zscores = [];
    rs.trodeStatus = [];

    for recNum = 1:length(ds.recs)
        % process individual recordings
        fprintf('processing recording %d of %d\n', recNum, length(ds.recs));
        [rs.results(recNum), newMontage] = processRecording(ds.recs(recNum), ds);
        
        % keep track of any bad electrodes throughout the recordings.  If a
        % single recording has a bad electrode, then that electrode can't
        % be counted in the aggregate data set
        if (isempty(rs.trodeStatus))
            rs.trodeStatus = rs.results(recNum).trodeStatus;
        else
            rs.trodeStatus = rs.trodeStatus & rs.results(recNum).trodeStatus;
        end
        
        % aggregate results
        rs.epochs  = cat(1, rs.epochs, rs.results(recNum).epochs);
        rs.zscores = cat(1, rs.zscores, rs.results(recNum).zscores);

        if (exist('Montage','var'))
            if (~compareMontages(Montage, newMontage, false))
                warning('montages are different in recNum %d than in previous recordings\n', recNum);
            end
        else
            Montage = newMontage;
        end
        
        if (isfield(rs, 'fs'))
            if (rs.fs ~= rs.results(recNum).fs)
                warning('sampling rate is different in recNum %d than in previous recordings\n', recNum);
            end
        else
            rs.fs = rs.results(recNum).fs;
        end
    end

    % create output directory to save results to if necessary
    outputDir = [myGetenv('output_dir') '\remoteAreas'];
    TouchDir(outputDir);
    
    % save results
    outputFilename = ['remoteAreas_' ds.exp '_rs'];
    outputFilepath = [outputDir '\' outputFilename];
    fprintf('saving output to %s\n', outputFilepath);
    save(outputFilepath, 'rs', 'ds');
    
    outputMontage = ['remoteAreas_' ds.exp '_rs_montage'];
    outputMontagepath = [outputDir '\' outputMontage];
    fprintf('saving output montage to %s\n', outputMontagepath);
    save(outputMontagepath, 'Montage');
    
end

function [result, Montage] = processRecording(rec, ds)

%     bad.epochs = [];
%     bad.zscores = [];
    
    % load and format data
    path = [rec.dir '\' rec.file];
    mpath = [rec.dir '\' rec.montage];
    
    [sig, sta, par] = load_bcidat(path);
    load(mpath);        

    fprintf('Montage: %s\n', Montage.MontageString);
    
    sig = double(sig);

    for field = fields(sta)';
        sta.(field{:}) = single(sta.(field{:}));
    end
    
    gugers = isfield(par,'CommonReference') | isfield(par,'CommonGroundReference');
    par = CleanBCI2000ParamStruct(par);

    fprintf('-----\n');
    fprintf(' File: %s\n', path);

    % determine control channel and range
    switch ds.task
        case 'rjb'
            controlChannels = str2double(par.Classifier);
            controlChannel = par.TransmitChList(controlChannels(:,1));
            if length(unique(controlChannel)) > 1
                error ('Multiple channels detected! %i', controlChannel)
            end
            clear controlChannels
            controlChannel = unique(controlChannel);

            lowRange = par.FirstBinCenter - par.BinWidth / 2;
            controlRange = [];
            for i=1:size(par.Classifier,1)
                bin = str2double(par.Classifier{i,2});
                controlRange = [controlRange (lowRange:lowRange+par.BinWidth) + (bin-1)*par.BinWidth];
            end
%             windowLength = par.WindowLength;
        case 'ud'
            % in the case of the 'ud' task, control channel and range
            % are specified in the ds files
            controlRange = ds.controlRange;
            controlChannel = ds.controlChannel;

%             windowLength = 0.5;
    end

    fprintf(' Control channel: %i\n', controlChannel);
    fprintf(' Control range: [%f-%f] Hz\n', min(controlRange), max(controlRange));    

    if (~gugers)
        fprintf(' Common average referencing, assuming neuroscans...\n');
        sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
    else
        fprintf(' Common average referencing, assuming gugers...\n');
        % assumes 64 channels are recorded from the guger
        sig = ReferenceCAR([16 16 16 16], Montage.BadChannels, sig);
    end
   
    obsMin = min(controlRange);
    obsMax = max(controlRange);
    
    % alternatively we could hard code these to 75 to 150
    % obsMin = 75;
    % obsMax = 150;
    
    notches = 60:60:(par.SamplingRate/2);
    notches = notches(notches > obsMin & notches < obsMax);
    
    if (~isempty(notches))
        fprintf(' Notching...\n');              
        sig = NotchFilter(sig, notches, par.SamplingRate);
    else
        fprintf(' Notching not necessary\n');
    end

    fprintf( ' Bandpassing...\n');
    hamp = abs(hilbert(BandPassFilter(sig, [obsMin obsMax], par.SamplingRate, 4)));

    % determine epochs of bci trials
    epochs = ones(length(find(diff(sta.TargetCode)~= 0)),1);
    epochs(:,1) = cumsum(epochs(:,1));
    newEpochAt = find(diff(sta.TargetCode) ~= 0);
    epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(sta.Running)]];

    feedbackStartAt = find(diff(sta.Feedback) ~= 0);
    feedbacks = [feedbackStartAt(1:end-1)+1 feedbackStartAt(2:end)];

    switch ds.task
        case 'ud'
            % hack for Kai's UD
            if size(feedbacks,1) < size(epochs,1)
                epochs(end - (size(epochs,1) - size(feedbacks,1)) + 1:end,:) = [];
            elseif size(feedbacks,1) > size(epochs,1)
                feedbacks(end - (size(feedbacks,1) - size(epochs,1)) + 1:end,:) = [];
            end
    end
    epochs(:,4:5) = feedbacks;
    epochs(:,6) = sta.TargetCode(epochs(:,3));
    epochs(:,7) = sta.ResultCode(epochs(:,3));
%     epochs(:,8) = 

    switch (ds.task)
        case 'rjb'
            epochs(:,8) = repmat(par.Adaptation(1), [size(epochs,1) 1]);
            epochs(:,9) = repmat(par.NormalizerGains(1), [size(epochs, 1) 1]);
            epochs(:,10) = repmat(par.NormalizerOffsets(1), [size(epochs, 1) 1]);
        otherwise
            epochs(:, 8) = zeros(size(epochs,1), 1);
            epochs(:, 9) = zeros(size(epochs,1), 1);
            epochs(:,10) = zeros(size(epochs,1), 1);
    end
    
    epochs(epochs(:,6) == 0,4:5) = epochs(epochs(:,6) == 0,2:3);

    allChanEpochMeans = zeros(size(epochs,1),size(sig,2));
    allChanEpochStds = zeros(size(epochs,1),size(sig,2));
%     allChanEpochZScores = zeros(size(epochs,1),size(sig,2));

    fprintf(' Calculating mean/std power for all epochs for all channels...\n')
    
    for chan=1:size(sig,2)
        for epoch = epochs'
            allChanEpochMeans(epoch(1),chan) = mean(hamp(epoch(4):epoch(5),chan));
            allChanEpochStds(epoch(1),chan) = std(hamp(epoch(4):epoch(5),chan));
        end
    end

    restMean = mean(allChanEpochMeans(epochs(:,6)==0,:),1);
    restStd = std(allChanEpochMeans(epochs(:,6)==0,:),1);

    allChanEpochZScores = bsxfun(@minus, allChanEpochMeans, restMean);
    allChanEpochZScores = bsxfun(@rdivide, allChanEpochZScores, restStd);

    result.epochs = epochs;
    result.zscores = allChanEpochZScores;

    badChannelFlag = zeros(sum(Montage.Montage),1);
    badChannelFlag(Montage.BadChannels) = 1;
    
    result.fs = par.SamplingRate;
    result.trodeStatus = ~badChannelFlag;
    result.trodeLabels = getLabelsFromMontage(Montage, 1:sum(Montage.Montage));    
end

function result = compareMontages(a, b, compareBadChans)
    result = true;
    
    if (length(a.Montage) ~= length(b.Montage))
        result = false;
        return;
    else
        result = result & (sum(a.Montage == b.Montage) == numel(a.Montage == b.Montage));
    end
    
    result = result & strcmp(a.MontageString, b.MontageString);
    
    if (length(a.MontageTokenized) ~= length(b.MontageTokenized))
        result = false;
        return;
    else
        for c = 1:length(a.MontageTokenized)
            result = result & strcmp(a.MontageTokenized{c}, b.MontageTokenized{c});            
        end
    end
    
    if (size(a.MontageTrodes, 1) ~= size(b.MontageTrodes,1))
        result = false;
        return;
    else
        result = result & (sum(sum(a.MontageTrodes == b.MontageTrodes)) == numel(a.MontageTrodes == b.MontageTrodes));
    end
    
    if (compareBadChans)
        if (length(a.BadChannels ~= b.BadChannels))
            result = false;
            return;
        else
            result = result & (sum(a.BadChannels == b.BadChannels) == numel(a.BadChannels == b.BadChannels));
        end
    end
    
end
