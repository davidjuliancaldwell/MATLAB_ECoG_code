% behavioral Analysis

cd([myGetenv('matlab_devel_dir') '\Experiment\1DBCI']);

% dsFile = 'ds/26cb98_ud_im_t_ds.mat'; load(dsFile); controlChannel = 36;
% dsFile = 'ds/38e116_ud_mot_h_ds.mat'; load(dsFile); controlChannel = 33; 
% dsFile = 'ds/4568f4_ud_mot_t_ds.mat'; load(dsFile); controlChannel = 56;
dsFile = 'ds/30052b_ud_im_t_ds.mat'; load(dsFile); controlChannel = 97;%29; 
% dsFile = 'ds/fc9643_ud_mot_t_ds.mat'; load(dsFile); controlChannel = 24; 
% dsFile = 'ds/mg_ud_im_t_ds.mat'; load(dsFile); controlChannel = 12; 
% dsFile = 'ds/04b3d5_ud_im_t_ds.mat'; load(dsFile); controlChannel = 45;


% not from original datasets
% load ds/fc9643_ud_im_t_ds.mat % *


% allsigs = [];
% allrests = [];
allscores = [];
alltargets = [];
allresults = [];

for recnum = 1:length(ds.recs)
    if(recnum == 1 && strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1) 
        controlChannel = 23;
        warning('little hack here');
    elseif (strcmp(dsFile, 'ds/fc9643_ud_mot_t_ds.mat')  == 1)
        controlChannel = 24;
    end
    
    [signals, states, parameters] = load_bcidat([ds.recs(recnum).dir '\' ds.recs(recnum).file]);
    load([ds.recs(recnum).dir '\' ds.recs(recnum).montage]);
    
    parameters = CleanBCI2000ParamStruct(parameters);
%     parameters.SamplingRate
    
%     % total hack, sorry!
%     if (parameters.SamplingRate == 2400)
%         signals = downsample(double(signals), 2);
%         states.Feedback = downsample(states.Feedback, 2);
%         states.TargetCode = downsample(states.TargetCode, 2);
%         states.ResultCode = downsample(states.ResultCode, 2);
%     end
    
    signals = double(signals);

    if (size(signals,2) == 64)
        signals = ReferenceCAR([16 16 16 16], Montage.BadChannels, signals);
    else
        signals = ReferenceCAR(Montage.Montage, Montage.BadChannels, signals);
    end
    
    cRange = getControlRange(parameters);

        fprintf(' Control channel: %i\n', controlChannel);
        fprintf(' Control range: [%f-%f] Hz\n', min(cRange), max(cRange));
    
%     signals = zscoreAgainstInterest(signals, states.TargetCode, 0);
    cSig = signals(:, controlChannel);
    cSig = NotchFilter(cSig, [60 120 180], parameters.SamplingRate);
    cSig = BandPassFilter(cSig, [min(cRange) max(cRange)], parameters.SamplingRate, 6);
%     cSig = notch(cSig, [60 120 180], parameters.SamplingRate, 6);
%     cSig = bandpass(cSig, min(cRange), max(cRange), parameters.SamplingRate, 6);
    cSig = abs(hilbert(cSig));
    
%     windowLength = parameters.WindowLength;
%     sumWindowLength = windowLength * parameters.SamplingRate;
%     convWindow = zeros(2*sumWindowLength,1);
%     convWindow(sumWindowLength+1:end) = 1 / sumWindowLength;
% 
%     fprintf(' Summing previous %i samples...\n', sumWindowLength);
%     cSig = conv(cSig,convWindow,'same');    
    
%     cSig = hilbAmp(cSig, [min(cRange) max(cRange)], parameters.SamplingRate);
%     cSig = log(cSig.^2);
%     cSig = zscoreAgainstInterest(cSig, states.TargetCode, 0);
%     cSig = GaussianSmooth(cSig, parameters.SamplingRate / 2);
%     cSig = lowpass(cSig, 3, parameters.SamplingRate, 4);
    
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

    sigs = zeros(fbOffset(1)-fbOnset(1), length(fbOnset));
    
    for c = 1:length(fbOnset)
        sigs(:,c) = cSig(fbOnset(c):(fbOffset(c)-1));
    end
  
    rests = zeros(restOffset(1)-restOnset(1), length(restOnset));
    
    for c = 1:length(restOnset)
        rests(:,c) = cSig(restOnset(c):(restOffset(c)-1));
    end
    
    sigavs = mean(sigs, 1);
    restavs = mean(rests, 1);
    reststds = std(rests, 1);

    % My Method, see notes from 2/1/12 in notebook
    scores = (sigavs - mean(restavs)) / std(restavs);
    % Tim's Method, see notes from 2/1/12 in notebook
%     scores = (sigavs - mean(restavs)) / mean(reststds);

    targets = states.TargetCode(fbOnset);
    results = states.ResultCode(fbOffset);
    
    allscores = [allscores; scores'];
    
    if (length(allscores > 94))
        x =5;
    end
    allresults = [allresults; results];
    alltargets = [alltargets; targets];
end

%% clean house
clear c cSig colorspec fb fbEvents fbOffset fbOnset recnum results signals sigs targets Montage controlChannel ds tsigs cRange rest restEvents restOffset restOnset restavs rests scores sigavs



%%

swin = 30;

up = 1;
down = 2;

upscores = allscores(alltargets == up);
downscores = allscores(alltargets == down);

upidxs = find(alltargets == up);
downidxs = find(alltargets == down);

results = allresults == alltargets;
upresults = allresults(alltargets == up) == up;
downresults = allresults(alltargets == down) == down;

figure;
plot(upidxs, upscores, 'r*'); hold on;
plot(downidxs, downscores, 'b*');

plot(upidxs, GaussianSmooth(upscores, swin), 'r');
plot(downidxs, GaussianSmooth(downscores, swin), 'b');

plot(find(results == 0), allscores(results == 0), 'ks');

%%
difference = interpDifference(GaussianSmooth(upscores, swin), alltargets == up, GaussianSmooth(downscores, swin), alltargets == down);
plot(difference, 'k', 'LineWidth', 2);