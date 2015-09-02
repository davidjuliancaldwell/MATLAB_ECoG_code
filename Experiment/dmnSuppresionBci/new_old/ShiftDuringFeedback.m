function rs = significanceScreen(ds, doPlots)
    if (nargin < 1)
        error('pass me some arguments');
    elseif (nargin < 2)
        doPlots = true;
    end
    
    if (~isstruct(ds))
        error('significanceScreen works on dataset structs, check your arguments.');
    end

    % initialize result set
    rs.restMeans = [];
    rs.targetingMeans = [];
    rs.feedbackMeans = [];
    rs.rewardMeans = [];
    
    % load each recording
    for recNum = 1:length(ds.recs)
        % get epoch averages for each recording
        % this should be a J cell vector, with each cell containing an KxL
        % matrix.  J is the number of electrodes in the recording,
        % M is the number of mean power values and L represents the four
        % phases of a BCI trial: (1) rest, (2) targeting, (3) feedback, 
        % (4) reward
        rs.results(recNum) = processRecording(ds.recs(recNum));
        
        rs.restMeans = cat(2, rs.restMeans, rs.results(recNum).restMeans);
        rs.targetingMeans = cat(2, rs.targetingMeans, rs.results(recNum).targetingMeans);
        rs.feedbackMeans = cat(2, rs.feedbackMeans, rs.results(recNum).feedbackMeans); 
        rs.rewardMeans = cat(2, rs.rewardMeans, rs.results(recNum).rewardMeans);
    end
    
    % calculate the quantity and statistical significance of the non-rest averages

    for trode = 1:size(rs.restMeans,1)
        rs.feedbackQ(trode) = signedSquaredXCorrValue(rs.feedbackMeans(trode,:), rs.restMeans(trode,:));
        
        [rs.feedbackP(trode), rs.feedbackH(trode)] = ...
            ranksum(rs.feedbackMeans(trode,:), rs.restMeans(trode,:));
        rs.feedbackChangePositive(trode) = median(rs.restMeans(trode,:)) < median(rs.feedbackMeans(trode,:));        
    end
        
    if (doPlots == true)
        showResults(ds, rs);
    end
end

function result = processRecording(rec)
    % set up the bad result
    bad.restEpochs = [];
    bad.targetingEpochs = [];
    bad.feedbackEpochs = [];
    bad.rewardEpochs = [];
    bad.goodTrials = [];
    
    bad.restMeans = [];
    bad.targetingMeans = [];
    bad.feedbackMeans = [];
    bad.rewardMeans = [];

    path = [rec.dir '\' rec.file];
    
    if (~exist(path, 'file'))
        warning('target recording file does not exist: %s\n', path);
        result = bad;
        return;
    end
    
    mpath = [rec.dir '\' rec.montage];
    
    if (~exist(mpath, 'file'))
        warning('target montage file does not exist: %s\n', path);
        result = bad;
        return;
    end
    
    % load in the signal
    
    switch (rec.type)
        case 'bci2k'
            [sig, sta, par] = load_bcidat(path);
            
            signals = double(sig);
            clear sig;
            
            feedback = sta.Feedback;
            targetCode = sta.TargetCode;
            resultCode = sta.ResultCode;
            clear sta;
            
            fs = par.SamplingRate.NumericValue;
            gugers = isfield(par,'CommonReference');
            
            clear par;
            
            load(mpath);
            
        case 'clinical'
            load(path);
            load(mpath);
            
            gugers = false;
            
            % should contain: signals, feedback, targetCode, resultCode, fs
            if (~exist('signals', 'var') || ~exist('feedback', 'var') || ~exist('targetCode', 'var') ...
                    || ~exist('resultCode', 'var') || ~exist('fs', 'var'))
                warning('clinical recording file, not formatted correctly for recording: %d.  Skippingfile\n', path);
                result = bad;
                return;
            end
        otherwise
            warning('tried to process unrecognized recording type: %s.  Skipping file\n', rec.type);
            result = bad;
            return;
    end
    
    % process the signal    
    if (~gugers)
        fprintf('Non Guger detected\n');
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    else
        fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    end
    
    powers = HilbAmp(signals, [70 200], fs).^2;
    
    % divide the signal in to epochs
    
    result.restEpochs = getAndCleanEpochs(powers, double(targetCode == 0), 1);
    result.targetingEpochs = getAndCleanEpochs(powers, double(targetCode ~= 0 & feedback == 0), 1);
    result.feedbackEpochs = getAndCleanEpochs(powers, double(feedback ~= 0 & resultCode == 0), 1);
    result.rewardEpochs = getAndCleanEpochs(powers, double(resultCode ~= 0), 1);
    s = getEpochs(resultCode ~= 0, 1);
    result.outcome = (resultCode(s) == targetCode(s));
    
    result.restMeans = squeeze(mean(result.restEpochs, 1));
    result.targetingMeans = squeeze(mean(result.targetingEpochs, 1));
    result.feedbackMeans = squeeze(mean(result.feedbackEpochs, 1));
    result.rewardMeans = squeeze(mean(result.rewardEpochs, 1));    
end

function epochs = getAndCleanEpochs(signals, codes, interest)
    [starts, endds] = getEpochs(codes, interest);
    
    idxs = find((endds-starts) ~= mode(endds-starts));
    starts(idxs) = [];
    endds(idxs) = [];
    
    epochs = getEpochSignal(signals, starts, endds);
end

function showResults(ds, rs)
    load([ds.surf.dir '\' ds.surf.file]);
    load([ds.trodes.dir '\' ds.trodes.file]);

    hs = rs.feedbackH();
    weights = rs.feedbackQ;
    weights(hs == 0) = 0;

    n = size(rs.feedbackMeans,2);
    figtitle = 'feedback';

    figure;

    side = ['r', 'l'];
    sideName = {'lateral', 'medial'};
    for d = 1:2
        subplot(1,2,d);
        ctmr_dot_plot(cortex, AllTrodes, weights, side(d), [-1 1], 40);
%             label_add(trodes, [.5 .5 .5], 60, true, false, numbers);
%             label_add(trodes(posTrodes,:), 'r', 60, true, false, numbers(posTrodes));
%             label_add(trodes(negTrodes,:), 'b', 60, true, false, numbers(negTrodes));
        title([sideName{d} ' - ' figtitle ' period, p < 0.05 (n = ' num2str(n) ')']);
        colorbar;
    end
    maximize(gcf);
    set(gcf, 'Name', figtitle);
        
end
