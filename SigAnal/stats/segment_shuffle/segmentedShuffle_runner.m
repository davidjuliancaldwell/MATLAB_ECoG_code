function segmentedShuffle_runner(subjid)
% load(strcat(subjid, '_basicanalysis.mat'), 'HGplvs', 'Montage', 'alphaPlvs', 'betaPlvs', 'deltaPlvs', 'fs', 'ifsPlv', 'numChans', 'subjid', 'trimmed_sig', 'thetaPlvs')
% load(strcat(subjid, '_phaseShuffled.mat'), 'HGplvs', 'Montage', 'alphaPlvs', 'betaPlvs', 'deltaPlvs', 'fs', 'ifsPlv', 'numChans', 'subjid', 'trimmed_sig', 'thetaPlvs')

load(strcat(subjid, '_phaseShuffled.mat'), 'Montage', 'fs', 'numChans', 'subjid', 'trimmed_sig')

alpha = hilbAmp(trimmed_sig, [8 12], fs).^2;
% 12-25 or 13-30?
beta = hilbAmp(trimmed_sig, [13 30], fs).^2;
HG = hilbAmp(trimmed_sig, [70 200], fs).^2;
theta = hilbAmp(trimmed_sig, [4 8], fs).^2;
delta = hilbAmp(trimmed_sig, [0 4], fs).^2;

% modified by DJC 2-8-2016 
ifsHG = bandpass(HG,0.1,1,fs);

% ifsHG = infraslowBandpass(HG);

numReps = 100;

windowSize = round(8 * fs);

fprintf('alpha \n');
[alphaPlvs, signif_alpha_plvs, alpha_pmax] = segmentedShuff_stats_oneband(alpha, windowSize, numReps);

fprintf('beta \n');
[betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);

fprintf('HG \n');
[HGplvs, signif_HG_plvs, HG_pmax] = segmentedShuff_stats_oneband(HG, windowSize, numReps);

%save(strcat(subjid, '_segmentShuffled')); %a waypoint save just in case

fprintf('theta \n');
[thetaPlvs, signif_theta_plvs, theta_pmax] = segmentedShuff_stats_oneband(theta, windowSize, numReps);

fprintf('delta \n');
[deltaPlvs, signif_delta_plvs, delta_pmax] = segmentedShuff_stats_oneband(delta, windowSize, numReps);

fprintf('amHG \n');
[ifsPlv, signif_ifsHG_plvs, ifsHG_pmax] = segmentedShuff_stats_oneband(ifsHG, windowSize, numReps);


shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.

clear 'alpha' 'beta' 'HG' 'theta' 'delt' 'ifsHG';


save(strcat(subjid, '_segmentShuffled'));

end