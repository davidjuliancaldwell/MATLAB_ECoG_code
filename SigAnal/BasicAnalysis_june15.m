%function [logHGPower, HGPower, logBetaPower, BetaPower, logAlphaPower, AlphaPower, ifsHG, ksHG] = QuickScreen_RestingState_KC ()

%from Kaitlyn, 9/16/2015 - edited by DJC 

%a cut down version of QuickScreen_StimulusPresentation for use with
%resting state data only
%this particular version for use with ResynchRunner for when the synch box
%is busted

%  ResynchRunner;

%% collect appropriate information necessary to run
% filename to process

filepath = promptForBCI2000Recording;
subjid = extractSubjid(filepath);

biHemi = input('Is this a strips pt with bilateral coverage (y/n)? ','s');

%% load data and montage (if exists) in to memory
[~, ~, ext] = fileparts(filepath);

if (strcmp(ext, '.dat'))
    [sig, sta, par] = load_bcidat(filepath); %gets these from ResynchRunner now
    montageFilepath = strrep(filepath, '.dat', '_montage.mat');
else
    load(filepath);
    sta.StimulusCode = stimulusCode; %added in to make script compatibile for clinical data
    par.SamplingRate.NumericValue = fs; %added in to make script compatibile for clinical data
    sig = signals;
    montageFilepath = strrep(filepath, '.mat', '_montage.mat');
end

if (exist(montageFilepath, 'file'))
    load(montageFilepath);
else
    % default Montage
    Montage.Montage = size(sig,2);
    Montage.MontageTokenized = {sprintf('Channel(1:%d)', size(sig,2))};
    Montage.MontageString = Montage.MontageTokenized{:};
    Montage.MontageTrodes = zeros(size(sig,2), 3);
    Montage.BadChannels = [];
    Montage.Default = true;
end

ReconHemi = input('Which hemisphere do you want to show? ("l", "r" or "both" )','s');

%% preprocess data
numChans = size(sig,2);
fs = par.SamplingRate.NumericValue;
sig = double(sig(:,1:numChans));

% common average re-reference.  Make sure to split up the gugers by
% amplifier bank using the function GugerizeMontage
%%

if (mod(fs, 1200) == 0)
%     sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
else
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
end

% notch filter to eliminate line noise
fprintf('notch filtering\n');
sig = notch(sig, [60 120 180], fs, 4);

bpsig = highpass(sig, 1, fs, 4);

clear 'sig', 'sta';

trimmed_sig = bpsig(2400:end-2400, :); %trim off those pesky end artifacts

clear 'bpsig'

fprintf('extracting HG power\n');
HGPower = hilbAmp(trimmed_sig, [70 200], fs).^2;
fprintf('extracting Beta power\n');
betaPower = hilbAmp(trimmed_sig, [12 18], fs).^2;
fprintf('extracting Alpha power\n');
alphaPower = hilbAmp(trimmed_sig, [8 12], fs).^2;
fprintf('extracting theta power\n');
thetaPower = hilbAmp(trimmed_sig, [4 8], fs).^2;
fprintf('extracting delta power\n');
deltaPower = hilbAmp(trimmed_sig, [0 4], fs).^2;

fprintf('extracting second order HG features\n');
ifsHG = infraslowBandpass(HGPower); %infraslow HG fluctuation 0.1-1hz

% resample to 60 Hz and run the even slower bandpass 0.01-0.1hz
newFs = 60; %NOTE: filter is designed for 60Hz. DO NOT CHANGE newFs WITHOUT ALSO CHANGING FILTER.
[p,q] = rat(60/fs);
resamp_HG = resample(HGPower, p, q);
rsHG = reallyslowBandpass(resamp_HG); %note this filter is designed for 60Hz resampled data

fprintf('calculating unicorn trajectories\n');
% ifsCorrs = corr(ifsHG);
ifsPlv = plv_revised(ifsHG);

% rsCorrs = corr(rsHG);
rsPlv = plv_revised(rsHG);

alphaPlv = plv_revised(alphaPower);
% alphaCorrs = corr(alphaPower);

betaPlv = plv_revised(betaPower);
% betaCorrs = corr(betaPower);

deltaPlv = plv_revised(deltaPower);
% deltaCorrs = corr(deltaPower);

thetaPlv = plv_revised(thetaPower);
% thetaCorrs = corr(thetaPower);

HGplv = plv_revised(HGPower);
% HGcorrs = corr(HGPower);



%%
% want PSI? run PSIrunner_single_permute1 here.
%%%%%%%[theta_psi, theta_masked, alpha_psi, alpha_masked, beta_psi, beta_masked, HG_psi, HG_masked, ifsHG_psi, ifsHG_masked, delta_psi, delta_masked] = PSIrunner_single_permute2(trimmed_sig, HGPower, fs);
%[theta_psi, theta_masked, alpha_psi, alpha_masked, beta_psi, beta_masked, HG_psi, HG_masked] = PSIrunner_single_permute1(trimmed_sig, fs);
clear 'deltaPower' 'thetaPower' 'alphaPower' 'betaPower' 'HGPower' 'ifsHG' 'rsHG' 'resamp_HG';

fprintf('saving\n');
save(strcat(subjid, '_basicanalysis.mat'), '-v7.3');

%end %end of function

