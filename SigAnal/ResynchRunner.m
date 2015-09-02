nChansToConsider = 16;

% hardcoded for your file of interest
% chansToIgnore = 49:58;    
% fname = fullfile(getSubjDir('854490'), 'Data', 'D3', '854490_baseline8001', '854490_baseline8S001R01.dat');
 
% an arbitrary bci2000 file
[sig, sta, par, filepath] = load_bcidatUI;
Montage = loadCorrespondingMontage(filepath);
chansToIgnore = Montage.BadChannels;


[sig, sta, par] = load_bcidat(filepath);    
    
[rsig, rsta] = resynchGugerData2(sig, sta, nChansToConsider, chansToIgnore);
    
%% if you want to check your work, this should give lags of zero
% crazyEights = 8:8:size(rsig, 2);
% crazyEights(ismember(crazyEights, chansToIgnore)) = [];
% nlags = calcLag(bandpass(double(rsig(:,crazyEights)), 70, 100, 1200, 4));
