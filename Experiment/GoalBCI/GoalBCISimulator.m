classdef GoalBCISimulator < handle
    properties
        steps
    end
    
    methods
        function o = GoalBCISimulator()
            steps = [];
        end
        
        function addSteps(o, sta, par)
            [~,~,~,~,~,~,feedbackStarts,feedbackEnds] = identifyFullEpochs(sta, par);

            for e = 1:length(feedbackStarts)
                if (sta.TargetCode(feedbackStarts(e)) ~= 9)
                    vals = feedbackStarts(e):par.SampleBlockSize.NumericValue:feedbackEnds(e);
                    vals = vals(2:end); % drop the first one because it includes the jump from prev location
                    pos = double(sta.CursorPosY(vals));
                    bads = pos == 61 | pos == 4033;

                    mSteps = diff(double(sta.CursorPosY(vals(~bads))));
                    o.steps = cat(1, o.steps, mSteps);
                end
            end                           
        end
        
        function simres = simulate(o, par, trialCount, repCount)
            DBG = 0;
            
            % derive the parameters below from the parameter files
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

            targets = zeros(repCount*trialCount, 1);
            results = zeros(repCount*trialCount, 1);
            ise = zeros(repCount*trialCount, 1);
            endingWell = zeros(repCount*trialCount, 1);
            reps = zeros(repCount*trialCount, 1);

            storageIndex = 0;

            repsteps = cat(1, o.steps, o.steps);
            
            for rep = 1:repCount    
%                 if (mod(rep,repCount/100)==0)
%                     fprintf('simulating rep %d of %d\n', rep, repCount);
%                 end

                % this assumes 8 targets all of equal probability
                mTargetSequence = randi(8, trialCount, 1);
%                 mTargetSequence = targetSequence(randperm(length(targetSequence)));

                for targetIndex = 1:length(mTargetSequence)

                    % reset state
                    stepsTaken = 0;
                    cursorYPos = cursorYStartPos;
                    dwellCounter = 0;
                    sequenceLoc = round(unifrnd(1, length(o.steps)));
                    temp = sequenceLoc;
                    
                    cursorPath = [];

                    storageIndex = storageIndex + 1;

                    % determine target bounds
                    targetBounds = [targetYPos(mTargetSequence(targetIndex)) - floor(targetDia(mTargetSequence(targetIndex))/2) ...
                                    targetYPos(mTargetSequence(targetIndex)) + floor(targetDia(mTargetSequence(targetIndex))/2)];                                        

%                     % simulate feedback
%                     while(stepsTaken < fbTimeBlocks && dwellCounter < dwellTimeBlocks)
%                         cursorYPos = cursorYPos + o.steps(sequenceLoc);
% 
%                         sequenceLoc = sequenceLoc + 1;
% 
%                         if (sequenceLoc > length(o.steps))
%                             sequenceLoc = 1;
%                         end
% 
%                         % if collision
%                         if (cursorYPos >= targetBounds(1) && cursorYPos <= targetBounds(2))
%                             dwellCounter = dwellCounter + 1;
%                         else
%                             dwellCounter = 0;                
%                         end
% 
%                         stepsTaken = stepsTaken + 1;
%                         cursorPath(stepsTaken) = cursorYPos;                
%                     end
                    
                    % simulate feedback w/o the loop
                    trialsteps = repsteps(temp:(temp + fbTimeBlocks - 1))';                    
                    cursorPath = cumsum(trialsteps) + cursorYStartPos;
                    
                    isDwelling = cursorPath >= targetBounds(1) & cursorPath <= targetBounds(2);

                    x = [isDwelling 0];
                    downs = find(diff(x)==-1);
                    ups   = find(diff(x)==1);
                    dwellCounts = downs-ups;
                    
                    targets(storageIndex) = mTargetSequence(targetIndex);
                    
                    if (any(dwellCounts >= dwellTimeBlocks))
                        winner = find(dwellCounts >= dwellTimeBlocks, 1, 'first');
                        isDwelling(1:ups(winner)-1) = 0;
                        dwellCount = cumsum(double(isDwelling));
                        
                        cursorPath((find(dwellCount >= dwellTimeBlocks, 1, 'first') + 1):end) = [];
                        results(storageIndex) = targets(storageIndex);
                    else
                        results(storageIndex) = 0;
                    end
                    
                    
                    mIse = calculateISE(map(cursorPath,0,4095,0,1)', targetYPosPct(mTargetSequence(targetIndex))/100, targetDiaPct(mTargetSequence(targetIndex))/100, samplesPerSecond / samplesPerBlock);

                    % save the results

%                     if (dwellCounter >= dwellTimeBlocks)
%                         results(storageIndex) = targets(storageIndex);
%                     else
%                         results(storageIndex) = 0;
%                     end

                    ise(storageIndex) = mIse;
                    %mtt(storageIndex) = stepsTaken * samplesPerBlock / samplesPerSecond;

                    wsFrac = (cursorPath(end) - WS_MIN) / (WS_MAX - WS_MIN);

                    if (ismember(targets(storageIndex), 1:4)) % it's an up target
                        endingWell(storageIndex) = wsFrac > .5;
                    else % it's a down target
                        endingWell(storageIndex) = wsFrac < .5;
                    end

                    reps(storageIndex) = rep;

                    % if we're in debug mode
                    if (DBG)
                        plot(cursorPath);
                        hold on;
%                         plot(cursorPath, 'r.--');
    
                        hline(targetBounds(1));
                        hline(targetBounds(2));
                        ylim([0 4095]);
                        hold off;
                        title(sprintf('tgt(%d), res(%d), ise(%1.2f), ew(%d)', targets(storageIndex), results(storageIndex), ise(storageIndex), endingWell(storageIndex)));
                                x = 5;
                    end            
                end
            end           
            
            simres.targets = targets;
            simres.results = results;
            simres.ise = ise;
            simres.endingWell = endingWell;
            simres.reps = reps;            
        end
        
        function [mu, lb, ub] = getCI(~, result, rep, type)
            ureps = unique(rep);            
            nreps = length(ureps);
            
            dist = zeros(nreps, 1);
            
            for i = 1:nreps
                dist(i) = mean(result(rep==ureps(i)));
            end
            
            mu = mean(dist);
            
            if (~exist('type', 'var'))
                type = 'both';
            end
            
            switch(type)
                case 'right'
                    lb = NaN;
                    ub = prctile(dist, 95);
                case 'left'
                    lb = prctile(dist, 5);
                    ub = NaN;
                case 'both'
                    lb = prctile(dist, 2.5);
                    ub = prctile(dist, 97.5);
                otherwise
                    error ('unknown type');
            end
        end
    end
end