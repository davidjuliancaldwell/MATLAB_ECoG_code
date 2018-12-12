SIDS = {'8adc5c', 'd5cd55', 'c91479', '7dbdec', '9ab7ab', '702d24', 'ecb43e'};

OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim','PrePost', 'figures');
TouchDir(OUTPUT_DIR);
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim','PrePost', 'meta');
TouchDir(META_DIR);

OUTPUT_DIR = char(System.IO.Path.GetFullPath(OUTPUT_DIR)); % modified DJC 7-23-2015 - temporary fix to save figures