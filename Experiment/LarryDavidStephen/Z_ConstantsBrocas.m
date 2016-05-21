SIDS = {'0b5a2e'};

OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BrocasStim', 'figures');
TouchDir(OUTPUT_DIR);
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BrocasStim', 'meta');
TouchDir(META_DIR);

OUTPUT_DIR = char(System.IO.Path.GetFullPath(OUTPUT_DIR)); % modified DJC 7-23-2015 - temporary fix to save figures