function [bursts,stims] = build_stim_table(smon,ttype,mode)
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
    
    % modified DJC
    % wherever burst type is equal to 2, use modify keeper to keep these
    % get rid of any burst labeled 2 where there was actually stimuli delivered smon(1,:)==1 (stimulation command sent, and
    % during type 2
    % keeper(bursts(5,:)==2)  = 1;
    if ((bursts(5,bursti) == 2) & (sum(smon(1,r)) == 0))
        keeper(bursti) = 1;
    end
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
stims(3,:) = mode(1,stims(2,:)); % identifying the mode at stim sample location

for stimi = 1:size(stims,2)
    if (stims(3,stimi)==1) % in burst (mode = 1 in bursts)
        stims(4:7, stimi) = NaN;
        stims(8, stimi) = ttype(stims(2,stimi));
    else
        
        tempPreBurst = find(stims(2,stimi) - bursts(3,:) > 0);
        %         tempPreBurst = tempPreBurst(bursts(5,tempPreBurst(1):tempPreBurst(end))~=2);
        if (isempty(tempPreBurst))
            stims(4:5, stimi) = NaN;
            
        else
            prebursti = tempPreBurst(end);
            stims(4, stimi) = prebursti; % labels the stim number with the preburst number
            stims(5, stimi) = stims(2,stimi)-bursts(3,prebursti); %samples separating the preburst stim from the prior burst
        end
        
        tempPostBurst = find(bursts(2,:) - stims(2, stimi) > 0);
        
        if (isempty(tempPostBurst))
            stims(6:7) = NaN;
        else
            postbursti = tempPostBurst(1);
            stims(6, stimi) = postbursti; % labels the stim number with the postburst number
            stims(7, stimi) = bursts(2, postbursti) - stims(2, stimi); % samples separating the postburst stim from the next burst
        end
        
        stims(8, stimi) = NaN;
    end
end

stims(:,(stims(3,:)==1 & stims(8,:)==2)) = [];

stims(1,:) = 1:size(stims,2); % indexing (enumerating) each individual stim sequentially


%% go back to the bursts array and figure out how many ct's for each burst

for bursti = 1:size(bursts, 2)
    bursts(4,bursti) = sum(stims(2,:) > bursts(2,bursti) & stims(2,:) < bursts(3, bursti)); % sums the number of stim that are logically greater than beginning of burst AND before end of burst
end

end

