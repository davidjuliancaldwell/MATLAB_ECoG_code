function segmentedShuffle_runner_PSI(subjid)
% load(strcat(subjid, '_basicanalysis.mat'), 'HGPSI', 'Montage', 'alphaPSI', 'betaPSI', 'deltaPSI', 'fs', 'ifsPSI', 'numChans', 'subjid', 'trimmed_sig', 'thetaPSI')
% load(strcat(subjid, '_phaseShuffled.mat'), 'HGPSI', 'Montage', 'alphaPSI', 'betaPSI', 'deltaPSI', 'fs', 'ifsPSI', 'numChans', 'subjid', 'trimmed_sig', 'thetaPSI')

load(strcat(subjid, '_phaseShuffled.mat'), 'Montage', 'fs', 'numChans', 'subjid', 'trimmed_sig')

% alpha = hilbAmp(trimmed_sig, [8 12], fs).^2;
% beta = hilbAmp(trimmed_sig, [13 30], fs).^2;
HG = hilbAmp(trimmed_sig, [70 200], fs).^2;
% theta = hilbAmp(trimmed_sig, [4 8], fs).^2;
% delta = hilbAmp(trimmed_sig, [0 4], fs).^2;
% ifsHG = infraslowBandpass(HG);

numReps = 1000;

windowSize = round(20 * fs);

fprintf('alpha \n');
[alphaPSI, signif_alpha_PSI, alpha_pmax] = segmentedShuff_stats_oneband_PSI(trimmed_sig, [8 13], windowSize, numReps);

fprintf('beta \n');
[betaBlvs, signif_beta_PSI, beta_pmax] = segmentedShuff_stats_oneband_PSI(trimmed_sig, [13 30], windowSize, numReps);

fprintf('HG \n');
[HGPSI, signif_HG_PSI, HG_pmax] = segmentedShuff_stats_oneband_PSI(trimmed_sig, [70 200], windowSize, numReps);

% save(strcat(subjid, '_segmentShuffled')); %a waypoint save just in case

fprintf('theta \n');
[thetaPSI, signif_theta_PSI, theta_pmax] = segmentedShuff_stats_oneband_PSI(trimmed_sig, [4 8], windowSize, numReps);

windowSize = round(60 * fs);

% fprintf('delta \n');
% [deltaPSI, signif_delta_PSI, delta_pmax] = segmentedShuff_stats_oneband_PSI(trimmed_sig, [0.1 4], windowSize, numReps);
% 
% fprintf('amHG \n');
% [ifsPSI, signif_ifsHG_PSI, ifsHG_pmax] = segmentedShuff_stats_oneband_PSI(HG, [0.1 1], windowSize, numReps);


shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.


save(strcat(subjid, '_segmentShuffled_PSI'));

end