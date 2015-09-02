
outputDir = fullfile(myGetenv('output_dir'), '1DBCI', 'cache');

% dsFile = 'ds/26cb98_ud_im_t_ds.mat'; controlChannel = 36; side = 'both'; el = 90; 
% dsFile = 'ds/38e116_ud_mot_h_ds.mat'; controlChannel = 33; side = 'both'; el = 90;
% dsFile = 'ds/4568f4_ud_mot_t_ds.mat'; controlChannel = 56; side = 'both'; el = 90;
% dsFile = 'ds/30052b_ud_im_t_ds.mat'; controlChannel = 29; side = 'r';
% dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; controlChannel = 24; side = 'r';
% dsFile = 'ds/mg_ud_im_t_ds.mat'; controlChannel = 12; side = 'both'; el = 270;
% dsFile = 'ds/04b3d5_ud_im_t_ds.mat'; controlChannel = 45; side = 'l';

% excluding this subject because of experimental probs
% dsFile = 'ds/8381b8_ud_mot_t_ds.mat'; controlChannel = 1; side = 'l';

load(dsFile);
 
sidx = strfind(dsFile, 'ds/') + length('ds/');
eidx = strfind(dsFile, '_');
eidx = eidx(1)-1;

subject = dsFile(sidx:eidx);

cacheFile = [pwd '\AllPower.m.cache\' subject '.mat'];

% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *

epochZs = [];
restZs = [];
targetCodes = [];
resultCodes = [];

badchans = [];

for recnum = 1:length(ds.recs)
    fprintf('processing recording %d of %d\n', recnum, length(ds.recs));

    if(recnum == 1 && strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1) 
        controlChannel = 23;
        warning('little hack here');
    elseif (strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1)
        controlChannel = 24;
    end

    if(strcmp(subject, '26cb98') == 1)
        badchans = union(badchans, 82);
        warning('little hack here');
    end

    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);

    badchans = union(badchans, Montage.BadChannels);

    parameters = CleanBCI2000ParamStruct(parameters);

    signals = double(signals);

    if (size(signals,2) == 64)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
        signals = signals(:, 1:sum(Montage.Montage));
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end

    cRange = getControlRange(parameters);

        fprintf('  Control channel: %i\n', controlChannel);
        fprintf('  Control range: [%f-%f] Hz\n', min(cRange), max(cRange));

    signals = NotchFilter(signals, [60 120 180], parameters.SamplingRate);
    signals = BandPassFilter(signals, [min(cRange) max(cRange)], parameters.SamplingRate, 6);
    signals = abs(hilbert(signals));
%     signals = log(signals.^2);

    [restStarts, restEnds] = getEpochs(states.TargetCode, 0);
    l = min(length(restStarts),length(restEnds));
    restStarts = restStarts(2:l); % ditch that first rest epoch
    restEnds   = restEnds(2:l);
    clear l;

    [runStarts, runEnds] = getEpochs((states.TargetCode & states.Feedback) ~= 0, 1);
    l = min(length(runStarts),length(runEnds));
    runStarts = runStarts(1:l);
    runEnds   = runEnds(1:l);
    clear l;

    epochSignal = getEpochSignal(signals, runStarts, runEnds);
    restSignal = getEpochSignal(signals, restStarts, restEnds);

    sigavs = squeeze(mean(epochSignal, 1));
    restavs = squeeze(mean(restSignal, 1));
%         reststds = std(restSignals, 1);

    % My Method, see notes from 2/1/12 in notebook
    restMuMtx = repmat(mean(restavs,2), 1, size(sigavs, 2));    
    restStdMtx = repmat(std(restavs,0,2), 1, size(sigavs, 2));
    
    epochZ = (sigavs - restMuMtx) ./ restStdMtx;
    restZ = (sigavs - restMuMtx) ./ restStdMtx;
    
%     fprintf('recnum: %d\n', recnum);
%     epochZ(36,:)
    
%     epochZ = (sigavs - repmat(mean(restavs, 2), 1, size(sigavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(sigavs, 2));
%     restZ  = (restavs - repmat(mean(restavs, 2), 1, size(restavs, 2))) ./ repmat(std(restavs, 0, 2), 1, size(restavs, 2)); 

    % Tim's Method, see notes from 2/1/12 in notebook
%     scores = (sigavs - mean(restavs)) / mean(reststds);

    targetCodes = [targetCodes; states.TargetCode(runStarts)];
    resultCodes = [resultCodes; states.ResultCode(runEnds + 1)];

    epochZs = [epochZ, epochZs];
    restZs = [restZs, restZ];
end

clearvars -except Montage badchans cRange controlChannel ds dsFile epochZs outputDir restZs resultCodes targetCodes side subject cacheFile
save(cacheFile);