function rs = TrendingPowers(ds, doPlots)

    % need to end up with zscores (relative to rest periods within that
    % trial) of all attempts at BCI.  these should be coded for up / down
    
    rs.aggregate.zscores = [];
    rs.aggregate.targetCodes = [];
    rs.aggregate.recNum = [];
    
    for recNum = 1:length(ds.recs)
        fprintf('recNum = %d\n', recNum);
        rs.results(recNum) = processRecording(ds.recs(recNum));
        
        rs.aggregate.zscores  = cat(2, rs.aggregate.zscores, rs.results(recNum).zscores);
        rs.aggregate.targetCodes = cat(1, rs.aggregate.targetCodes, rs.results(recNum).targetCodes);
        rs.aggregate.recNum   = cat(2, rs.aggregate.recNum, recNum*ones(size(rs.results(recNum).targetCodes))');
    end

    if (doPlots)
        showResults(ds, rs);
    end
end

% function result = processRecording(rec)
%     bad.zscores = [];
%     bad.targetCodes = [];
%     
%     path = [rec.dir '\' rec.file];
%     mpath = [rec.dir '\' rec.montage];
%     
%     switch(rec.type)
%         case 'bci2k'
%             [sig, sta, par] = load_bcidat(path);
%             load(mpath);        
% 
%             signals = double(sig);
%             
%             fs = par.SamplingRate.NumericValue;
%             
%             targetCode = sta.TargetCode;
%             feedback   = sta.Feedback;
%             
%             gugers = isfield(par,'CommonReference');
%             
%         case 'clinical'
%             load(path);
%             load(mpath);
% 
%             if (~exist('signals', 'var') || ~exist('targetCode', 'var') || ...
%                     ~exist('feedback', 'var') || ~exist('fs', 'var'))
%                 warning('clinical recording file, not formatted correctly for recording: %d.  Skipping file\n', path);
%                 result = bad;
%                 return;
%             end
%              
%             gugers = false;
%             
%         otherwise
%             warning('unknown filetype of %s entered, should be bci2k or clinical', rec.type);
%             result = bad;
%     end
% 
%     if (gugers)
%         signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
%     else
%         signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
%     end
%     
%     signals = signals(:,rec.trodes);
%     signals = notch(signals, [60 120 180], fs, 4);
%     hamp = hilbAmp(signals, [70 200], fs);
% %     hpwr = hamp.^2;
%     hpwr = hamp;
%     lhpwr = log(hpwr);
%   
%     rest = lhpwr(targetCode == 0, :);
%     
%     zscored = (lhpwr - repmat(mean(rest), length(lhpwr), 1)) ./ repmat(std(rest), length(lhpwr), 1);
%     
% %     zscored = zscore(lhpwr);
%     
%     [starts, ends] = getEpochs(targetCode ~= 0, 1);
%     most = mode(ends - starts);
%     idxs = find((ends - starts) ~= most);
%     if (~isempty(idxs))
%         ends(idxs) = [];
%         starts(idxs) = [];
%     end
%     
%     epochs = getEpochSignal(zscored, starts, ends);
%     
%     result.zscores = squeeze(mean(epochs,1));
%     result.targetCodes = targetCode(starts);    
% end

function result = processRecording(rec)
    bad.zscores = [];
    bad.targetCodes = [];
    
    path = [rec.dir '\' rec.file];
    mpath = [rec.dir '\' rec.montage];
    
    switch(rec.type)
        case 'bci2k'
            [sig, sta, par] = load_bcidat(path);
            load(mpath);        

            signals = double(sig);
            
            fs = par.SamplingRate.NumericValue;
            
            targetCode = sta.TargetCode;
            feedback   = sta.Feedback;
            
            gugers = isfield(par,'CommonReference');
            
        case 'clinical'
            load(path);
            load(mpath);

            if (~exist('signals', 'var') || ~exist('targetCode', 'var') || ...
                    ~exist('feedback', 'var') || ~exist('fs', 'var'))
                warning('clinical recording file, not formatted correctly for recording: %d.  Skipping file\n', path);
                result = bad;
                return;
            end
             
            gugers = false;
            
        otherwise
            warning('unknown filetype of %s entered, should be bci2k or clinical', rec.type);
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
%     hpwr = hamp.^2;
%     hpwr = hamp;
%     lhpwr = log(hpwr);
  
%     rest = lhpwr(targetCode == 0, :);
    
%     zscored = (lhpwr - repmat(mean(rest), length(lhpwr), 1)) ./ repmat(std(rest), length(lhpwr), 1);
    
%     zscored = zscore(lhpwr);
  
    [rStarts, rEnds] = getEpochs(targetCode, 0);
    most = mode(rEnds - rStarts);
    idxs = find((rEnds - rStarts) ~= most);
    if (~isempty(idxs))
        rEnds(idxs) = [];
        rStarts(idxs) = [];
    end
    
    [starts, ends] = getEpochs(targetCode ~= 0, 1);
    most = mode(ends - starts);
    idxs = find((ends - starts) ~= most);
    if (~isempty(idxs))
        ends(idxs) = [];
        starts(idxs) = [];
    end
    
    restEpochs = getEpochSignal(hamp, rStarts, rEnds);
    epochs = getEpochSignal(hamp, starts, ends);
    
    restMeans = squeeze(mean(restEpochs,1));
    means     = squeeze(mean(epochs, 1));
    
    result.zscores = (means - repmat(squeeze(mean(restMeans,2)),1,size(means,2))) ./ repmat(std(restMeans,0,2), 1, size(means,2));    
    result.targetCodes = targetCode(starts);    
end

function showResults(ds, rs)
    colors = {'r','b','g','c','y'};

    dimension = ceil(sqrt(size(rs.aggregate.zscores,1)));
    figure;
    
    for trode = ds.electrodes
        trodeIdx = find(trode == ds.electrodes);
        
        subplot(dimension,dimension,trodeIdx);
        
        codes = double(unique(rs.aggregate.targetCodes));
        for c = 1:length(codes)
            code = codes(c);
            idxs = find(rs.aggregate.targetCodes  == code);
            
            plot (idxs, rs.aggregate.zscores(trodeIdx, idxs), [colors{code} '.']);             
            hold on;
            
            p = polyfit(idxs, rs.aggregate.zscores(trodeIdx, idxs)', 1);
            plot (idxs, idxs*p(1) + p(2), colors{code}, 'LineWidth', 2);
        end
        title(sprintf('electrode %d', trode));
        axis tight;
        
%         lims = get(gca, 'YLim');
%         lims(2) = min(lims(2), 0.6);
%         lims(1) = max(lims(1), -0.6);
%         
%         set(gca, 'YLim', lims);
%         set(gca, 'YLim', [-0.5 0.5]);
    end
end

% function showResult(file, result)
%     figure;
%     
%     numTrodes = size(result.passEpochs, 2);
%     dim = ceil(sqrt(numTrodes));
%     
%     t = (1:size(result.passEpochs,1)) / result.fs;
%     
%     for trode = 1:size(result.passEpochs,2)
%         if (result.trodeStatus(trode) == 1)
%             subplot(dim,dim,trode);
%             if(~isempty(result.passEpochs))
%                 plot(t, mean(squeeze(result.passEpochs(:,trode,:)),2));
%             end
%             hold on;
%             if(~isempty(result.failEpochs))
%                 plot(t, mean(squeeze(result.failEpochs(:,trode,:)),2), 'r');
%             end
%             axis tight;
%             highlight(gca, [result.restStart result.restEnd], [], [0.9 0.9 0]);
%             highlight(gca, [result.fbStart result.fbEnd], [], [0 0.9 0]);
%             title(result.trodeLabels{trode});
% 
%             xlabel('trial time (s)');
%             ylabel('HG hilbert amp');
%         end
%     end
% 
%     legend({['success (N = ' num2str(size(result.passEpochs,3)) ')'], ...
%             ['failure (N = ' num2str(size(result.failEpochs,3)) ')']}, ...
%             'Location', 'EastOutside');
% 
%     mtit(strrep(file,'_', '\_'), 'xoff', 0, 'yoff', 0.05);
%     maximize(gcf);
% %     SaveFig([pwd '\octb09'], strrep(file, '.dat', ''));
% end