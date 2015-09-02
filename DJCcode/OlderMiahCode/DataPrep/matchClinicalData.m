function [clinicalData, offsets] = matchClinicalData(clinicalFilename, bci2kFilename, promptForNoise, cChans, bChans, sChans)

    % TODO - re enable arg error check
%     if(nargin < 2)
%         error('insufficient input args');
%     elseif(nargin < 3)
%         promptForNoise = true;
%         channels = [];
%     elseif(nargin < 4)
%         channels = [];
%     end
    % end TODO
    
    if (length(cChans) ~= length(bChans))
        error('number of clinical channels to compare and bci2k channels to compare must be equal');
    end
    
    if (~exist(clinicalFilename, 'file'))
        error('clinical file does not exist: %s', clinicalFilename);
    end
    if (~exist(bci2kFilename, 'file'))
        error('bci2k file does not exist: %s', clinicalFilename);
    end

%     info = dir(bci2kFilename);
%     
%     bci2kRecTime = parseRecTime(info.date);
%     
% %     bci2kRecTime.H = bci2kRecTime.H - 1; % set the clock back
%     if (bci2kRecTime.M >= 30)
%         bci2kRecTime.M = bci2kRecTime.M - 30;
%     else
%         bci2kRecTime.M = bci2kRecTime.M + 30;
%         bci2kRecTime.H = bci2kRecTime.H - 1;
%     end
    
    fprintf('loading bci2k file\n');
    [signals, ~, parameters] = load_bcidat(bci2kFilename);

    try 
        recTimeNum = datenum(parameters.StorageTime.Value, 'ddd mmm dd HH:MM:SS yyyy');
    catch exception
        try
            recTimeNum = datenum(parameters.StorageTime.Value, 'yyyy-mm-ddTHH:MM:SS');
        catch ex2
            throw(exception)
        end
    end
    
    rewindNum  = recTimeNum - (15/60/24);
    rewindVec  = datevec(rewindNum);
    
    % check to make sure the recordings were made on the same day
    edf = sdfopen(clinicalFilename, 'r', 1);
    
    for d = 1:3
       if(edf.T0(d) ~= rewindVec(d))
           error('recordings were not made on the same day,\n  clinical recording was %s,\n  bci2000 recording was %s', ...
               datestr(edf.T0), datestr(recTimeNum));
       end
    end
    
    bci2kRecTime.H = rewindVec(4);
    bci2kRecTime.M = rewindVec(5);
    bci2kRecTime.S = rewindVec(6);
    
%     % TODO REMOVE ME!!!!
%     fsignals = zeros(size(signals));
%     
%     parfor c = 1:length(signals)
%         fsignals(c,:) = reshape(reshape(signals(c,:),8,8)',64,1);
%     end
%     signals = fsignals; clear fsignals;
%     
%     % /end remove
    
    
    montageFilename = strrep(bci2kFilename, '.dat', '_montage.mat');
    if (exist(montageFilename,'file'))
        load(montageFilename);
    else
        warning('No montage file found.  Assuming all channels are good.\n');
        Montage.BadChannels = [];
    end
    
    % update Montage.BadChannels to only include bChans
    % and drop the channels we're not interested in
    sigsToKeep = zeros(size(signals,2), 1);
    isBad = zeros(size(signals,2), 1);

    sigsToKeep(bChans) = 1;
    isBad(Montage.BadChannels) = 1;
    
    signals = signals(:,sigsToKeep == 1);
    isBad = isBad(sigsToKeep == 1);
    Montage.BadChannels = find(isBad);
    
    % now work with the signals
    signals = double(signals);
    bci2kFs = parameters.SamplingRate.NumericValue;
    bci2kRecLength = size(signals,1)/bci2kFs;
    
    fprintf('loading clinical file\n');
    [clinSignals, clinFs] = getClinicalData(clinicalFilename, bci2kRecTime, bci2kRecLength + (30*60), cChans); % add 30 minutes to the time

    
    % TODO - put me back in
%     if (~isempty(channels))
%         [clinSignals, clinFs] = getClinicalData(clinicalFilename, bci2kRecTime, bci2kRecLength + 3600, channels);
%     else
%         [clinSignals, clinFs] = getClinicalData(clinicalFilename, bci2kRecTime, bci2kRecLength + 3600);
%         clinSignals = clinSignals(:,2:end); % discard the status channel
%     end
    % END - TODO
    
    if(strendswith(clinicalFilename, '.edf'))
        clinicalMontageFilename = strrep(clinicalFilename, '.edf', '_montage.mat');
    else
        clinicalMontageFilename = strrep(clinicalFilename, '.rec', '_montage.mat');
    end
    
    if (exist(clinicalMontageFilename, 'file'))
        temp = Montage;
        load(clinicalMontageFilename);
        ClinicalMontage = Montage;
        ClinicalMontage.BadChannels = ClinicalMontage.BadChannels - 1;
        Montage = temp;
        clear temp;
    else
        warning('No clinical montage file found.  Assuming all channels are good.');
        ClinicalMontage.BadChannels = [];
    end
    
    % round clinical sampling rate
%     clinFs = round(clinFs / 10) * 10;
    
% TEMP LETS TRY FILTERING FOR A FREQ RANGE
    clinSignals = BandPassFilter(clinSignals, [5 100], clinFs, 4);
    signals = BandPassFilter(signals, [5 100], bci2kFs, 4);
    
    if (length(clinSignals) > 2^20)
        % need to downsample
        dsFactor = ceil(length(clinSignals) / 2^20);
        workingClinSignals = downsample(clinSignals, dsFactor);
    else
        dsFactor = 1;
        workingClinSignals = clinSignals;
    end
    workingClinFs = clinFs / dsFactor;
    
    if (promptForNoise)
        fprintf('finding noise epochs\n');
        % eliminate noise from clinical signal
        idxs = ~ismember(cChans, ClinicalMontage.BadChannels);
        
        [starts, stops] = getNoiseEpochs(workingClinSignals(:,idxs));
        
        means = mean(workingClinSignals, 1);
        for c = 1:length(stops)
            workingClinSignals(starts(c):stops(c),:) = repmat(means, stops(c)-starts(c)+1, 1);
        end

        % eliminate noise from bci2k signal
        idxs = ~ismember(bChans, Montage.BadChannels);
        
        [starts, stops] = getNoiseEpochs(signals(:,idxs));
        means = mean(signals, 1);
        for c = 1:length(stops)
            signals(starts(c):stops(c),:) = repmat(means, stops(c)-starts(c)+1, 1);
        end
    end
    
    chansToSeek = min(size(signals,2), size(workingClinSignals, 2));

    offsets = zeros(chansToSeek, 1);
    corrs   = zeros(size(offsets));

    % let's try for each channel we pulled from the sdf
    fprintf('calculating cross correlations\n');
    for c = 1:size(offsets,1)
        fprintf('  chan %d\n', c);
%         fprintf('  chan %d\n', channels(c));
        if (sum(Montage.BadChannels == c) == 0 && sum(ClinicalMontage.BadChannels == c) == 0)
%             % don't do plots
%             [offset, corr] = alignData(workingClinSignals(:,c), signals(:,c),  workingClinFs, bci2kFs, 1, false, true);
            % do plots
            [offset, corr] = alignData(workingClinSignals(:,c), signals(:,c),  workingClinFs, bci2kFs, 1, true, true);
            offsets(c) = offset;
            corrs(c) = corr;
        else
            fprintf('skipping channel %d because it was bad in either the BCI2K Montage or the Clinical Montage\n');
            offsets(c) = -1;
            corrs(c) = 0;
        end
    end

    offset = mode(offsets(offsets ~= -1));
    offset = offset * dsFactor; % up to our original sample rate

    lengthToSave = round(size(signals,1)/bci2kFs*clinFs - 1);

    if (isempty(sChans))
        [clinSignals, ~] = getClinicalData(clinicalFilename, bci2kRecTime, bci2kRecLength + (30*60));    
    else
        [clinSignals, ~] = getClinicalData(clinicalFilename, bci2kRecTime, bci2kRecLength + (30*60), sChans');    
    end
    
    clinicalData = clinSignals(offset:offset+lengthToSave, :);
end

% function timeVec = parseRecTime(dateString)
% 
% %     result = textscan(temp, '%s %s %d %d:%d:%d %d');
% % 
% %     switch (result{2})
% %         case 'Jan'
% %             month = 1
% %     timeVec = [result{7}, month, result{3}, result{4}, result{5}, result{6}];
% end

function [starts, stops] = getNoiseEpochs(workingClinSignals)
    starts = [];
    stops = [];
    fid = figure;
    
    % for now, just show up to three trodes worth
    plot(workingClinSignals(:,1:min(3,size(workingClinSignals,2))));
    
    cues = {'start', 'stop'};
    isStart = true;
    cont = 0;
    c = 1;
    title(sprintf('click to identify noise epochs (%s), ''d'' to end.  Don''t screw up, you can''t undo.', cues{double(~isStart)+1}));
    
    while cont == 0
        km=waitforbuttonpress;
        switch km
            case 1
                key = get(fid,'CurrentCharacter');
                if key=='d'
                    cont = 1;
                    break;
                end
                if key=='u'
                    % undoprevious
                end
            case 0
                mClickInfo = get(gca);
                m_pos=round(mClickInfo.CurrentPoint(1,1:2));
                x = m_pos(1);
                
                if(isStart)
                    fprintf('start(%d) recorded: %d\n', c, x);
                    starts(c) = x;
                else
                    fprintf('stop(%d) recorded: %d\n', c, x);
                    stops(c) = x;
                    c = c + 1;
                end
                isStart = ~isStart;
                title(sprintf('click to identify noise epochs (%s), ''d'' to end.  Don''t screw up, you can''t undo.', cues{double(~isStart)+1}));
        end
    end
    
    close(fid);
end