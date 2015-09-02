%% chance performance was calculated using the following assumptions:
%% * subjects do not have volitional control over neural activity
%% * visual or other task stimuli may, to some degree, drive neural activity
%% * this version DOES NOT assume statistical independence of moment to moment movement
%%
%% as a result, to calculate chance performance on the task, we determined sequences of cursor movement
%% and synthesized multiple BCI trials based on random starting points in this sequence.

tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};
SUBCODES = {'S1','S2','S3','S4'};

% the modifiable parameters
RUNS_TO_SIMULATE = 50000;
DBG = 0;

%% step 1 - determine trajectory sequences

FORCE_TRAJ = false;
trajFile = fullfile(META_DIR, 'trajectories.mat');

if (FORCE_TRAJ || ~exist(trajFile, 'file'))
    fprintf('extracting trajectories.\n');
    
    steps = [];

    for c = 1:length(SIDS);
        subjid = SIDS{c};
        subcode = SUBCODES{c};

        fprintf ('processing %s: \n', subcode);

        [files, ~, Montage] = goalDataFiles(subjid);

        for fileIdx = 1:length(files)
            fprintf('  file %d of %d\n', fileIdx, length(files));

            [~, sta, par] = load_bcidat(files{fileIdx});   

            if (fileIdx == 1 && strcmp(subjid, '6b68ef'))                        
                for fieldname = fieldnames(sta)'
                    temp = sta.(fieldname{:});
                    sta.(fieldname{:}) = temp(4e4:end, :);
                end            
            end

            [~,~,~,~,~,~,feedbackStarts,feedbackEnds] = identifyFullEpochs(sta, par);

            for e = 1:length(feedbackStarts)
                if (sta.TargetCode(feedbackStarts(e)) ~= 9)
                    vals = feedbackStarts(e):par.SampleBlockSize.NumericValue:feedbackEnds(e);
                    vals = vals(2:end); % drop the first one because it includes the jump from prev location
                    pos = double(sta.CursorPosY(vals));
                    bads = pos == 61 | pos == 4033;

                    mSteps = diff(double(sta.CursorPosY(vals(~bads))));
                    steps = cat(1, steps, mSteps);
                end
            end                
        end
    end

    save(trajFile, 'par', 'samplesPerBlock', 'samplesPerSecond', 'targetDiaPct', 'targetYPosPct', 'steps');
else
    fprintf('using previously extracted trajectories.\n');
    load(trajFile);
end

%% visualize these just to keep us sane
figure
subplot(211);
plot(steps);
subplot(212);
hist(steps, 40);

%% now simulate BCI trials based on this sequence of steps

simFile = fullfile(META_DIR, sprintf('sim_results_%d.mat', RUNS_TO_SIMULATE));

FORCE_SIM = true;

if (FORCE_SIM || ~exist(simFile, 'file'))
    fprintf('simulating chance BCI performance.\n');
    
    tic;

    % derive the parameters below from the parameter files
    targetSequence = par.TargetSequence.NumericValue;

    samplesPerBlock = double(par.SampleBlockSize.NumericValue);
    samplesPerSecond = double(par.SamplingRate.NumericValue);
    fbTimeBlocks = double(par.FeedbackDuration.NumericValue) / (samplesPerBlock / samplesPerSecond);
    dwellTimeBlocks = double(par.TargetDwellTime.NumericValue) / (samplesPerBlock / samplesPerSecond);

    WS_MIN = 0;
    WS_MAX = 4095;

    targetDiaPct = par.Targets.NumericValue(:, 4);
    targetDia = floor(map(targetDiaPct, 0, 100, WS_MIN, WS_MAX));

    targetYPosPct = par.Targets.NumericValue(:, 2);
    targetYPos = floor(map(targetYPosPct, 0, 100, WS_MIN, WS_MAX));

    cursorDia = floor(map(double(par.CursorWidth.NumericValue), 0, 100, WS_MIN, WS_MAX));
    cursorYStartPos = floor(map(50, 0, 100, WS_MIN, WS_MAX));

    cursorMin = floor(WS_MIN + cursorDia / 2);
    cursorMax = floor(WS_MAX - cursorDia / 2);

    targets = [];
    results = [];
    mtt = [];
    ise = [];
    storageIndex = 0;

    for run = 1:RUNS_TO_SIMULATE    
        if (mod(run,RUNS_TO_SIMULATE/100)==0)
            fprintf('simulating run %d of %d\n', run,RUNS_TO_SIMULATE);
        end

        mTargetSequence = targetSequence(randperm(length(targetSequence)));

        for targetIndex = 1:length(mTargetSequence)

            % reset state
            stepsTaken = 0;
            cursorYPos = cursorYStartPos;
            dwellCounter = 0;
            sequenceLoc = round(unifrnd(1, length(steps)));
            mIse = 0;

            cursorPath = [];

            if (DBG)
                errorValues = [];
            end

            % determine target bounds
            targetBounds = [targetYPos(mTargetSequence(targetIndex)) - floor(targetDia(mTargetSequence(targetIndex))/2) ...
                            targetYPos(mTargetSequence(targetIndex)) + floor(targetDia(mTargetSequence(targetIndex))/2)];                                        

            % simulate feedback
            while(stepsTaken < fbTimeBlocks && dwellCounter < dwellTimeBlocks)
                cursorYPos = cursorYPos + steps(sequenceLoc);

                sequenceLoc = sequenceLoc + 1;

                if (sequenceLoc > length(steps))
                    sequenceLoc = 1;
                end

                % if collision
                if (cursorYPos >= targetBounds(1) && cursorYPos <= targetBounds(2))
                    dwellCounter = dwellCounter + 1;
                else
                    dwellCounter = 0;                
                end

                stepsTaken = stepsTaken + 1;
                cursorPath(stepsTaken) = cursorYPos;                

                if (DBG)
                    if (cursorYPos >= targetBounds(1) && cursorYPos <= targetBounds(2))
                        errorValues(stepsTaken) = 0;
                    else
                        errorValues(stepsTaken) = min(abs(cursorYPos - targetBounds(1)), abs(cursorYPos - targetBounds(2)));
                    end
                    fprintf('%d: %d %d %d %d\n', stepsTaken, cursorYPos, targetBounds(1), targetBounds(2), cursorYPos >= targetBounds(1) && cursorYPos <= targetBounds(2));
                end
            end

            mIse = calculateISE(map(cursorPath,0,4095,0,1)', targetYPosPct(mTargetSequence(targetIndex))/100, targetDiaPct(mTargetSequence(targetIndex))/100, samplesPerSecond / samplesPerBlock);

            if (DBG)
                plot(cursorPath);
                hold on;
                plot(errorValues, 'r');
                hline(targetBounds(1));
                hline(targetBounds(2));
                ylim([0 4095]);
                hold off;
                x = 5;
            end

            % save the results
            storageIndex = storageIndex + 1;
            targets(storageIndex) = mTargetSequence(targetIndex);

            if (dwellCounter >= dwellTimeBlocks)
                results(storageIndex) = targets(storageIndex);
            else
                results(storageIndex) = 0;
            end

            ise(storageIndex) = mIse;
            mtt(storageIndex) = stepsTaken * samplesPerBlock / samplesPerSecond;                
        end
    end

    toc

    save(simFile);
else
    fprintf('using previously simulated chance BCI performance.\n');    
    load(simFile);
end

%% now determine average performance on our metrics with 95% CIs

% reshape the data
keepers = targets ~= 9;

targetSequence(targetSequence==9) = [];
targets(~keepers) = [];
results(~keepers) = [];
ise(~keepers) = [];
mtt(~keepers) = [];

targets = reshape(targets, length(targetSequence), length(targets) / length(targetSequence));
results = reshape(results, length(targetSequence), length(results) / length(targetSequence));
ise     = reshape(ise,     length(targetSequence), length(ise)     / length(targetSequence));
mtt     = reshape(mtt,     length(targetSequence), length(mtt)     / length(targetSequence));

% hitrate chance performance
hitrate = mean(targets == results,1);
figure;
hist(hitrate, length(unique(hitrate)));
title('hitrate');
[lbound, ubound] = extractCI(hitrate, .95);

vline(mean(hitrate), 'r');
vline(lbound);
vline(ubound);

fprintf('hitrate chance performance %f [%f, %f]\n', mean(hitrate), lbound, ubound);

hit.mu = mean(hitrate);
hit.lb = lbound;
hit.ub = ubound;

% ise chance performance
isescore = mean(ise, 1);

figure;
hist(isescore, 40);
title('ise');
[lbound, ubound] = extractCI(isescore, .95);

vline(mean(isescore), 'r');
vline(lbound);
vline(ubound);

fprintf('ise chance performance %f [%f, %f]\n', mean(isescore), lbound, ubound);

err.mu = mean(isescore);
err.lb = lbound;
err.ub = ubound;

save(fullfile(META_DIR, 'chance.mat'), 'hit', 'err');



