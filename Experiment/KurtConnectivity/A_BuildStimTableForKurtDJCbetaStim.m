%% for subject 9ab7ab, based off of beta stim work
% modified 3/8/2016 - to look at CCEP thresholding levels for 0b5a2e

%% Constants
close all;clear all;clc
Z_ConstantsKurtConnectivity;
addpath c:/users/david/desktop/research/raolab/matlab/code/experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%

sid = input('What was the subject ID? 0b5a2e?','s');

switch sid
    case '9ab7ab'
        tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock('BetaPhase-3');
    case '0b5a2e'
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_EP\0b5a2e_EP';
        block = 'EP-1';
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        tic;
        [smon, info] = tank.readWaveEvent('SMon', 2);
        smon = smon';
        
        fs = info.SamplingRateHz;
        
        stim = tank.readWaveEvent('SMon', 4)';
        toc;
        
        tic;
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        beta = tank.readWaveEvent('Blck', 1)';
        
        raw = tank.readWaveEvent('Blck', 2)';
        
        toc;
end

%% build a burst table with the following
% 1 - burst id
% 2 - burst start sample
% 3 - burst stop sample
% 4 - nstims in burst (do last)
% 5 - type of conditioning (0 = falling, 1 = rising)

bursts = [];

dmode = diff([0 mode 0]);
dmode(end-1) = dmode(end);

bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);
dmode(end) = [];

if (exist('ttype', 'var'))
    bursts(5,:) = ttype(bursts(2,:));
else
    bursts(5,:) = 0;
end

% discard the bursts that don't have any stimuli
keeper = false(1, size(bursts, 2)); % all zeros
for bursti = 1:size(bursts, 2) % check each burst for stimuli
    r = bursts(2,bursti):bursts(3,bursti); % 1 burst
    keeper(bursti) = sum(smon(1, r)) > 0; % checking burst for stim, saves answer as logical 1 if bursts present
end

bursts(:, ~keeper) = []; % using the "find logical NOT" command, fills any logical 0 in keepeer (no stim present) with a [] deleting the column

bursts(1,:) = 1:size(bursts,2); % numbers each of the positions in the first row of "bursts"...indexing them

%% build a table with the following
% 1 - stim id
% 2 - sample number where occurred
% 3 - mode (0 = test, 1 = conditioning)
% 4 - burst before (burst # before this stim)
% 5 - n samples after previous burst (that this stim occured)
% 6 - burst after (burst # following this stim)
% 7 - n samples before previous burst (that this stim occured)
% 8 - stim type (rising or falling edge of beta)

stims = [];

stims(2,:) = find(smon(1,:)==1); % identify samples when smon = 1 (stimualtion command sent)
stims(1,:) = 1:size(stims,2); % indexing (enumerating) each individual stim sequentially
stims(3,:) = mode(1,stims(2,:)); % identifying the mode at stim sample location

for stimi = 1:size(stims,2)
    if (stims(3,stimi)==1) % in burst (mode = 1 in bursts)
        stims(4:7, stimi) = NaN;
        stims(8, stimi) = ttype(stims(2,stimi));
    else
        prebursti = find(stims(2,stimi) - bursts(3,:) > 0, 1, 'last'); %systematically tests stim sample locations vs burst locations
        if (isempty(prebursti))
            stims(4:5, stimi) = NaN;
        else
            stims(4, stimi) = prebursti; % labels the stim number with the preburst number
            stims(5, stimi) = stims(2,stimi)-bursts(3,prebursti); %samples separating the preburst stim from the prior burst
        end
        
        postbursti = find(bursts(2,:) - stims(2, stimi) > 0, 1, 'first'); %finds first stim loc after a burst
        if (isempty(postbursti))
            stims(6:7) = NaN;
        else
            stims(6, stimi) = postbursti; % labels the stim number with the postburst number
            stims(7, stimi) = bursts(2, postbursti) - stims(2, stimi); % samples separating the postburst stim from the next burst
        end
        
        stims(8, stimi) = NaN;
    end
end

%% go back to the bursts array and figure out how many ct's for each burst

for bursti = 1:size(bursts, 2)
    bursts(4,bursti) = sum(stims(2,:) > bursts(2,bursti) & stims(2,:) < bursts(3, bursti)); % sums the number of stim that are logically greater than beginning of burst AND before end of burst
end

%% save the result to intermediate file for future use
save(fullfile(META_DIR, ['9ab7ab' '_tables.mat']), 'bursts', 'fs', 'stims');
