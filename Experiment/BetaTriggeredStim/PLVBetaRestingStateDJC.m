%% 1-26-2016 - PLV for resting states, before and after, beta power too -DJC

%%
close all;clear all;clc
Z_ConstantsRest
%there appears to be no montage for this subject currently - assume all are
%64 channel grids right now which is fine because it's from TDT recording

for i = 1:length(SIDS)
    sid = SIDS{i};
    switch(sid)
        case '8adc5c'
            
        case 'd5cd55'
            
        case 'ecb43e'
            % load pre
            subjid = 'ecb43e';
            load('D:\BigDataFiles\ecb43e_PAC_prestim.mat')
            BlckPre = data;
            clear data
            
            % load post
            load('D:\BigDataFiles\ecb43e_PAC_poststim.mat')
            BlckPost = data;
            clear data
            
                        Montage.MontageTokenized = {'Grid(1:64)'};
            Montage.MontageString = Montage.MontageTokenized{:};
            Montage.MontageTrodes = zeros(64, 3);
            Montage.BadChannels = [54];
            Montage.Default = true;
        case '0b5a2e'
            subjid = '0b5a2e';
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            
            sid = '0b5a2e';
            
            Montage.MontageTokenized = {'Grid(1:64)'};
            Montage.MontageString = Montage.MontageTokenized{:};
            Montage.MontageTrodes = zeros(64, 3);
            Montage.BadChannels = [25 29];
            Montage.Default = true;
            
    end
    
end

Montage.Montage = 64;

sid = '0b5a2e';

Montage.MontageTokenized = {'Grid(1:64)'};
Montage.MontageString = Montage.MontageTokenized{:};
Montage.MontageTrodes = zeros(64, 3);
Montage.BadChannels = [25 29];
Montage.Default = true;

% get electrode locations
locs = trodeLocsFromMontage(sid, Montage, false);

%% some more preprocessing if desired, NEED MONTAGE LOADED

% post load
% subjid = '0b5a2e';
% suffixPost = 'postStimRestDecimated';
% load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
% BlckPost = Blck;
% clear Blck;
%
% % pre load
% suffixPre = 'preStimRestDecimated';
% load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
% BlckPre = Blck;
% clear Blck;

% account for bad channels
bads = Montage.BadChannels;

% common average rereference
BlckPreCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPre);
BlckPostCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPost);
clear BlckPre;
clear BlckPost;

% notch filter at 60
BlckPreCARnotch = notch(BlckPreCAR,60,fs);
BlckPostCARnotch = notch(BlckPostCAR,60,fs);
clear BlckPreCAR;
clear BlckPostCAR;

% high pass filter at 0.5
BlckPreCARfiltered = highpass(BlckPreCARnotch,0.5,fs);
BlckPostCARfiltered = highpass(BlckPostCARnotch,0.5,fs);
clear BlckPreCARnotch;
clear BlckPostCARnotch;

%% post state - 2-8-2016
post_trimmed_sig = BlckPostCARfiltered;
trimmed_sig = post_trimmed_sig;

% 12-25 or 13-30? Kaitlyn started with 13-30, i did 12-25 to match Jared -
% DJC 2-8-2016
beta = hilbAmp(trimmed_sig, [12 25], fs).^2;

numReps = 100;

windowSize = round(8 * fs);


fprintf('beta \n');
[betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);

shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.

clear 'alpha' 'beta' 'HG' 'theta' 'delt' 'ifsHG';


save(fullfile(META_DIR, [sid '_postSegmentedShuffled']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax');

%% pre state 2-8-2016

clear 'betaBlvs' 'beta_pmax' 'signif_beta_plvs' 'trimmed_sig'
trimmed_sig = BlckPreCARfiltered;

beta = hilbAmp(trimmed_sig, [12 25], fs).^2;

numReps = 100;

windowSize = round(8 * fs);


fprintf('beta \n');
[betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);

shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.

clear 'alpha' 'beta' 'HG' 'theta' 'delt' 'ifsHG';

save(fullfile(META_DIR, [sid '_preSegmentedShuffled']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax');




%% old post 1-26-2016
post_beta = hilbAmp(post_trimmed_sig, [13 30], fs).^2;
post_HG = hilbAmp(post_trimmed_sig,[70 200],fs).^2;

post_beta_plv = plv_revised(post_beta);

% lifted from changeTScoreWithStats.m

% 8 second winwodws
power = post_beta;
windowSize = round(8 * fs);
numReps = 1000;
nsegments = numReps;

segmented_data = zeros(windowSize, numChans, nsegments);

for segment = 1:nsegments;
    segmented_data(:,:,segment) = power(1:windowSize,:);
    power(1:windowSize, :) = [];
end

segPlvs = zeros(size(power,2), size(power,2), 0);

for segment = 1:nsegments;
    
    thisWindow = segmented_data(:,:,segment);
    thisWindowPlv = plv_revised(thisWindow);
    
    segPlvs = cat(3, segPlvs, thisWindowPlv);
    
end

% std_dev = std(segPlvs, 0, 3);
%
% tmeans=(mean(segPlvs,3))./std_dev;
% from the original differences script - may want to use this later, but not now

real_plvs = mean(segPlvs,3);

% phase shuffle data

% lifted from fastPhaseShuffle_95thavgs.m

numChans = size(originalData,2);
betaPlvMaxDist = [];

for reps = 1:20;
    disp(reps);
    %shuffle the data
    shuffledData = phase_shuffleFD(originalData);
    %trim the ends for artifacts
    shuffledData = shuffledData(1000:end-1000,:);
    %bandpasses
    HGShuffled = hilbAmp(shuffledData, [70 200], fs).^2;
    
    betaShuffled = hilbAmp(shuffledData, [13 30], fs).^2;
    
    %corrs and plvs for each band
    HGshuffledPlv = plv_revised(HGShuffled);
    
    betashuffledPlv = plv_revised(betaShuffled);
    
    HGshuffledPlv(HGshuffledPlv==1) = 0;
    betashuffledPlv(betashuffledPlv==1) = 0;
    
    
    for i = 1:numChans;
        for j = 1:numChans;
            if ismember(i, badChans) || ismember(j,badChans);
                HGshuffledPlv(i,j) = 0;
                betashuffledPlv(i,j) = 0;
            end
        end
    end
    
    HGPlvMaxDist = [HGPlvMaxDist prctile(squeeze(HGshuffledPlv),95)];
    betaPlvMaxDist = [betaPlvMaxDist prctile(squeeze(betashuffledPlv),95)];
    
end

ifsPlvMax = mean(ifsPlvMaxDist);
rsPlvMax = mean(rsPlvMaxDist);

HGPlvMax = mean(HGPlvMaxDist);
alphaPlvMax = mean(alphaPlvMaxDist);
betaPlvMax = mean(betaPlvMaxDist);

thetaPlvMax = mean(thetaPlvMaxDist);
deltaPlvMax = mean(deltaPlvMaxDist);


maskedIfsPlvs = zeros(size(realIfsPlvs));
maskedRsPlvs = zeros(size(realRsPlvs));
maskedHGPlvs = zeros(size(realHGPlvs));
maskedbetaPlvs = zeros(size(realbetaPlvs));
maskedalphaPlvs = zeros(size(realalphaPlvs));
maskedthetaPlvs = zeros(size(realthetaPlvs));
maskeddeltaPlvs = zeros(size(realdeltaPlvs));


for i = 1:numChans;
    for j=1:numChans;
        if realIfsPlvs(i,j) >= ifsPlvMax;
            maskedIfsPlvs(i,j) = realIfsPlvs(i,j);
        end
        if realRsPlvs(i,j) >= rsPlvMax;
            maskedRsPlvs(i,j) = realRsPlvs(i,j);
        end
        if realHGPlvs(i,j) >= HGPlvMax;
            maskedHGPlvs(i,j) = realHGPlvs(i,j);
        end
        if realbetaPlvs(i,j) >= betaPlvMax;
            maskedbetaPlvs(i,j) = realbetaPlvs(i,j);
        end
        if realalphaPlvs(i,j) >= alphaPlvMax;
            maskedalphaPlvs(i,j) = realalphaPlvs(i,j);
        end
        if realthetaPlvs(i,j) >= thetaPlvMax;
            maskedthetaPlvs(i,j) = realthetaPlvs(i,j);
        end
        if realdeltaPlvs(i,j) >= deltaPlvMax;
            maskeddeltaPlvs(i,j) = realdeltaPlvs(i,j);
        end
    end
end

end

shuffledSig = phase_shuffleFD(post_trimmed_sig);

power_shuffle = hilbAmp(shuffledSig, [13 30], fs).^2;



%%

% difference matrices show POSITIVE values if pair had HIGHER connectivity
% in post session, NEGATIVE value of LOWER in post session

% load(strcat(subjid,'_basicanalysis'), 'Montage', 'biHemi', 'ReconHemi', 'numChans')

windowSize = round(10 * fs); %sliding window will be 10 second long segments
numChans = 64;
% should add multiple comparisons?


fprintf('beta\n');
[diff_beta_plv, beta_pmin, beta_pmax] = changeTScoreWithStats(beta, post_beta, windowSize);
masked_beta_plvdiff = NaN(numChans, numChans);
for i = 1:numChans;
    for j=1:numChans;
        if beta_pmax(i,j)<=0.025 || beta_pmin(i,j)<0.025;
            masked_beta_plvdiff(i,j) = diff_beta_plv(i,j);
        end
    end
end

masked_beta_plvdiff2 = masked_beta_plvdiff;
masked_beta_plvdiff2(bads,:) = NaN;
masked_beta_plvdiff2(:,bads) = NaN;

