function [ISE, ISEByTime, ISEByTrial] = deriveISE(sta, par)

    % find the centerpoints of all targets,
    % the 1st index is for the "NULL" target
    targetYs = [0; par.Targets.NumericValue(:,2)];
    
    % convert to a percentage and scale to screen resolution
    targetYs = targetYs / 100;
%     targetYs = targetYs * par.WindowHeight.NumericValue;

    targetRadii = [0; par.Targets.NumericValue(:,5)/2];
    targetRadii = targetRadii / 100;
    targetYRadii = targetRadii;% * par.WindowHeight.NumericValue
    
    
    targetYPos = targetYs(sta.TargetCode+1);
    targetYMin = targetYPos - (targetYRadii(sta.TargetCode+1) .* double(sta.TaskDiff));
    targetYMax = targetYPos + (targetYRadii(sta.TargetCode+1) .* double(sta.TaskDiff));
    
    cursorYPos = double(sta.CursorPosY) / 4096;
%     cursorYPos = cursorYPos * par.WindowHeight.NumericValue;
   
    cursorYMin = cursorYPos - (par.CursorWidth.NumericValue/2 / 100);
    cursorYMax = cursorYPos + (par.CursorWidth.NumericValue/2 / 100);

    fb = double(sta.Feedback);
    [starts, ends] = getEpochs(fb, 1, false);
        
    marginalError = (targetYPos - cursorYPos).^2 .* double(fb);
    
    for c = 0:par.SampleBlockSize.NumericValue
        marginalError(starts+c) = 0;
    end
    
    ISEByTime = cumsum(marginalError);
    
    ISEByTrial = zeros(length(starts), 1);
    
    for c = 1:length(starts)
        ISEByTrial(c) = sum(marginalError(starts(c):ends(c)));
    end
    
    ISE = ISEByTime(end);
    
    figure, plot(targetYPos); hold on;
    plot(targetYMin, ':');
    plot(targetYMax, ':');
    
    plot(cursorYPos, 'r');
    plot(cursorYMin, 'r:');
    plot(cursorYMax, 'r:');
    
    plot(marginalError, 'k');
    
end