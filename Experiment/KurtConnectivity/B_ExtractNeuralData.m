%% Extract neural data for Kurt Connectivity

eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
eco = toRow(notch(eco, 60, efs, 2, 'causal'));