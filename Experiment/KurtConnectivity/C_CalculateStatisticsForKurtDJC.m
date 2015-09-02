%% this script calculates the normalized z_score, comparing the mean of -10 to -5 msec before stimulation, to 10-30 msec after stimulation 

% 
preSamp = (0.2*fsSig);
postSamp = (0.1*fsSig);

sig_z = normalize_plv(stimulated_means',rest_means');