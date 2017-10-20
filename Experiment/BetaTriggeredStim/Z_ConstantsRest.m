% edited DJC 2-9-2016 to get rid of 8a..no good. and already did 0b5a2e, so
% get rid of that for now 
SIDS = {'d5cd55', 'c91479', '7dbdec', '9ab7ab', '702d24', 'ecb43e', '0b5a2e'};

OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim', 'restAnalysis','output_fullFreq_range_10_6_2017');
TouchDir(OUTPUT_DIR);
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim', 'restAnalysis','meta_fullFreq_range');
TouchDir(META_DIR);

OUTPUT_DIR = char(System.IO.Path.GetFullPath(OUTPUT_DIR)); % modified DJC 7-23-2015 - temporary fix to save figures