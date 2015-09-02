% behavioral Analysis

cd([myGetenv('matlab_devel_dir') '\Experiment\1DBCI']);
outputDir = [myGetenv('output_dir') '\remoteAreas\AllPower\'];

% dsFile = 'ds/26cb98_ud_im_t_ds.mat'; controlChannel = 36; side = 'both'; el = 90; 
% dsFile = 'ds/38e116_ud_mot_h_ds.mat'; controlChannel = 33; side = 'both'; el = 90;
% dsFile = 'ds/4568f4_ud_mot_t_ds.mat'; controlChannel = 56; side = 'both'; el = 90;
% dsFile = 'ds/30052b_ud_im_t_ds.mat'; controlChannel = 29; side = 'r';
% dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; controlChannel = 24; side = 'r';
% dsFile = 'ds/mg_ud_im_t_ds.mat'; controlChannel = 12; side = 'both'; el = 270;
% dsFile = 'ds/04b3d5_ud_im_t_ds.mat'; controlChannel = 45; side = 'l';

load(dsFile);
 
sidx = strfind(dsFile, 'ds/') + length('ds/');
eidx = strfind(dsFile, '_');
eidx = eidx(1)-1;

subject = dsFile(sidx:eidx);

cacheFile = [pwd '\AllPower.m.cache\' subject '.mat'];

% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *

if(~exist(cacheFile, 'file'))
    
    allscores = [];
    alltargets = [];
    allresults = [];

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

        rest = double(states.TargetCode);
        rest(rest == 0) = 3;
        rest(rest <  3) = 0;
        rest(rest == 3) = 1;

        restEvents = [1; diff(rest)]; % trial starts in rest
        restOnset = find(restEvents == 1);
        restOffset = find(restEvents == -1);
        restOnset = restOnset(2:end);
        restOffset = restOffset(2:end);

        fb = double(states.Feedback);

        fbEvents = [0; diff(fb)];
    %     fbOnset = find(fbEvents == 1); % + round(0.0*parameters.SamplingRate); % 500 ms response time
        fbOnset = find(fbEvents == 1) + round(0.5*parameters.SamplingRate);
        fbOffset = find(fbEvents == -1);

        if length(fbOnset) > length(fbOffset)
            fbOnset = fbOnset(1:length(fbOffset));
        end

        epochSignals = zeros(fbOffset(1)-fbOnset(1), length(fbOnset), size(signals, 2));

        for c = 1:length(fbOnset)
            epochSignals(:,c,:) = signals(fbOnset(c):(fbOffset(c)-1), :);
        end

        restSignals = zeros(restOffset(1)-restOnset(1), length(restOnset), size(signals, 2));

        for c = 1:length(restOnset)
            restSignals(:,c,:) = signals(restOnset(c):(restOffset(c)-1), :);
        end

        sigavs = squeeze(mean(epochSignals, 1));
        restavs = squeeze(mean(restSignals, 1));
        reststds = std(restSignals, 1);

        % My Method, see notes from 2/1/12 in notebook
        scores = (sigavs - repmat(mean(restavs, 1), size(sigavs, 1), 1)) ./ repmat(std(restavs, 1), size(sigavs, 1), 1);
        % Tim's Method, see notes from 2/1/12 in notebook
    %     scores = (sigavs - mean(restavs)) / mean(reststds);

        targets = states.TargetCode(fbOnset);
        results = states.ResultCode(fbOffset);

        allscores = [allscores; scores];
        allresults = [allresults; results];
        alltargets = [alltargets; targets];
    end

    allscores(:, badchans) = 0;

    save(cacheFile);
else
    fprintf('using cache file.\n');
    load(cacheFile);
end

%%

fprintf('  plotting correlations: %s\n', subject);

up = 1;
down = 2;

upscores = allscores(alltargets == up, :);
downscores = allscores(alltargets == down, :);

upcorrs = zeros(size(allscores, 2), 1);
downcorrs = zeros(size(allscores, 2), 1);

for chan = 1:size(allscores, 2)
    temp = corrcoef(upscores(:,controlChannel), upscores(:,chan));
    upcorrs(chan) = temp(2,1);
    temp = corrcoef(downscores(:,controlChannel), downscores(:,chan));
    downcorrs(chan) = temp(2,1);
end


% ys = 1:size(allscores,2);
% figure, plot(ys, upcorrs, ys, downcorrs, ys, diffcorrs);

upcorrs(badchans) = NaN;
downcorrs(badchans) = NaN;
diffcorrs(badchans) = NaN;

