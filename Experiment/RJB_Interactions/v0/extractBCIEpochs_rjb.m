function [data, t, fs, tx, targets, results, Montage] = extractBCIEpochs_rjb(files, doPreprocess)
    % pre-check files
    if (isempty(files))
        error('number of files must be greater than zero');
    end
    if (~exist('doPreprocess', 'var'))
        doPreprocess = true;
    end

    % load everything in to memory and do some basic checking
    bads = [];
    
    for fileIdx = 1:length(files)
        [sig{fileIdx}, sta{fileIdx}, par{fileIdx}] = load_bcidat(files{fileIdx});
        Montage{fileIdx} = loadCorrespondingMontage(files{fileIdx});
        
        if (fileIdx > 1)
            if (size(sig{fileIdx},2) ~= nChans)
                error('number of channels differs in file %d', fileIdx);
            end
            if (par{fileIdx}.SamplingRate.NumericValue ~= fs)
                error('sampling rate differs in file %d', fileIdx);
            end
            
            [newTrialLength, t, tx] = determineTrialStructure(par{fileIdx});
            if (trialLength ~= newTrialLength)
                error('trial length differs in file %d', fileIdx);
            end            
            
            % TODO check montage for consistency
            
        else
            [trialLength, t, tx] = determineTrialStructure(par{fileIdx});
        end
        
        nChans = size(sig{fileIdx},2);
        fs = par{fileIdx}.SamplingRate.NumericValue;
        bads = union(bads, Montage{fileIdx}.BadChannels);
    end
    
    Montage = Montage{1};
    Montage.BadChannels = bads;
    
    % actually pull out the data in to windows
    data =[];
    targets = [];
    results = [];
    
    for fileIdx = 1:length(files)
        [starts, ~, ~, ~, ~, ~, ~, ends] = identifyFullEpochs_rjb(sta{fileIdx}, par{fileIdx});        
        
        msig = double(sig{fileIdx});
        
        if (doPreprocess)
            if (mod(fs, 1200) == 0)
                msig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, msig);
            else
                msig = ReferenceCAR(Montage.Montage, Montage.BadChannels, msig);
            end
            msig = notch(msig, [60 120 180], fs, 4);
        end
        
        data = cat(3, data, getEpochSignal(msig, starts, ends+1));
        targets = cat(1, targets, sta{fileIdx}.TargetCode(ends));
        results = cat(1, results, sta{fileIdx}.ResultCode(ends));
    end
end
function [L, t, tx] = determineTrialStructure(par)
    % returns the length of a trial in samples
    sbs = par.SampleBlockSize.NumericValue;
    fs = par.SamplingRate.NumericValue;
    
    % bci2000 enforces full sampling blocks
    iti  = round(par.ITIDuration.NumericValue * fs / sbs) * sbs;
    pre  = round(par.PreFeedbackDuration.NumericValue * fs / sbs) * sbs;
    fb   = round(par.FeedbackDuration.NumericValue * fs / sbs) * sbs;
    post = round(par.PostFeedbackDuration.NumericValue * fs / sbs) * sbs;
        
    L = iti + pre + fb + post;
    t = ((1:L) / fs);
    
    tx.iti = 1 / fs;
    tx.pre = (iti + 1) / fs;
    tx.fb = (iti + pre + 1) / fs;
    tx.post = (iti + pre + fb + 1) /fs;
end