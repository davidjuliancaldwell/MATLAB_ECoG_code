%% function to look at burst timing of signal and the raw signal around that
% written by DJC 1-8-2015

% load bursts table , this is first for 0b5a2e
close all;clear all;clc
Z_Constants
SUB_DIR = fullfile(myGetenv('subject_dir'));

sid = input('what is is the subject sid\n','s');

switch(sid)
    case '8adc5c'
        % sid = SIDS{1};
        tp = strcat(SUB_DIR,'\8adc5c\data\D6\8adc5c_BetaTriggeredStim');
        block = 'Block-67';
        
    case 'd5cd55'
        % sid = SIDS{2};
        tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
        block = 'Block-49';
        
    case 'c91479'
        % sid = SIDS{3};
        tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
        block = 'BetaPhase-14';
        
    case '7dbdec'
        % sid = SIDS{4};
        tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
        block = 'BetaPhase-17';
        
    case '9ab7ab'
        %             sid = SIDS{5};
        tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        block = 'BetaPhase-3';
        
    case '702d24'
        tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
        block = 'BetaPhase-4';
        
    case 'ecb43e' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
        block = 'BetaPhase-3';
        
    case '0b5a2e' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-2';
        
    case '0b5a2ePlayback' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-4';
        
    case '0a80cf' % added DJC 5-24-2016
        tp = strcat(SUB_DIR,'\0a80cf\data\d10\0a80cf_BetaStim\0a80cf_BetaStim');
        block = 'BetaPhase-4';
        
    case '3f2113' % added DJC 7-23-2015
        tp =  strcat(SUB_DIR,'\',sid,'\data\data\d6\BetaStim\BetaStim');
        block = 'BetaPhase-5';
        
    otherwise
        error('unknown SID entered');
end
%%

if strcmp(sid,'0b5a2ePlayback')
    load(fullfile(META_DIR, ['0b5a2e' '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    
    delay = 577869;
elseif strcmp(sid,'0b5a2e')
    % below is for original miah style burst tables
    %         load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
    % below is for modified burst tables
    load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
else % for other subjects ( not the last 2) 
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
end
% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];

% adjust stim and burst tables for 0b5a2e playback case

if strcmp(sid,'0b5a2ePlayback')
    
    stims(2,:) = stims(2,:)+delay;
    bursts(2,:) = bursts(2,:) + delay;
    bursts(3,:) = bursts(3,:) + delay;
    
end

%%
burst_hist(sid,bursts)
burst_timing(sid,bursts)


%% this part doesnt work yet!
% burst_signalExtract(bursts,raw)

