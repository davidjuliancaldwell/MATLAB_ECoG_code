SIDS = {'8adc5c', 'd5cd55', 'c91479', '7dbdec', '9ab7ab', '702d24', 'ecb43e','0b5a2e','0b5a2ePlayback','0a80cf','3f2113','3f2113Playback'};
prefixDirectory = 'C:\Users\david';

% Neuromodulation2016Conference
% CSNESiteVisit

%OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim', 'BetaStimManuscript');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim', 'PeakToPeakEP'); % DJC 4-30-2018 

TouchDir(OUTPUT_DIR);
META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'BetaTriggeredStim', 'meta');
TouchDir(META_DIR);

OUTPUT_DIR = char(System.IO.Path.GetFullPath(OUTPUT_DIR)); % modified DJC 7-23-2015 - temporary fix to save figures