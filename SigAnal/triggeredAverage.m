%% triggeredAverage.m
%  jdw - 11APR2011
%
% Changelog:
%   11APR2011 - originally written
%
% this function computes the triggered average of the trigger signal as
% well as the src signals.
%
% function [averages, windows, trigAverage, trigWindows] =
%   triggeredAverage(trigger, threshold, minTrigDist, srcs, preSamp, 
%     postSamp, figTitle, figFilename)
%
% Parameters:
%   trigger - the signal to seek through for trigger events
%   threshold - is the value which trigger must be higher than to
%     cause a trigger event.  Trigger events are local peaks in the trigger
%     signal.
%   minTrigDist - is the minimum number of samples between trigger events.
%     If zero or less than zero, this parameter will be ignored.
%   srcs - the signals that are captured upon a trigger event.  The
%     dimensions of this matrix should be [MxN] where N is the number of
%     different srcs.
%   preSamp - the number of samples before the trigger event to capture
%   postSamp - the number of samples after the trigger event to capture
%   figTitle (optional) - if supplied, the function will display a figure
%     with the triggers, their average and each of the srcs with their
%     average as well.
%   figFilename (optional) - if supplied (in conjunction with figTitle),
%     the function will save the generated image to figFilename
%
% Return Values:
%   averages - a KxN matrix where K is the width of the averaging window as
%     defined by K = preSamp + postSamp + 1.  It contains the triggered
%     average of each src.
%   windows - a KxNxX matrix that contains the windows that are averaged to
%     generate the averages mentioned above.  There are X windows.
%   trigAverage - a vector of length K that contains the triggered average
%     of the trigger.
%   trigWindows - a KxX matrix that contains the windows that are averaged
%     to generate the trigAverage mentioned above.
%
function [averages, windows, trigAverage, trigWindows] = triggeredAverage(...
    trigger, threshold, minTrigDist, srcs, preSamp, postSamp, figTitle, figFilename)

    trigAverage = [];
    trigWindows = [];
    
    averages = [];
    windows  = [];
    
    srcCount = size(srcs, 2);
    
    if (srcCount <= 0)
        error('number of source signals must be greater than 0.');
        return;
    end
    
    if (minTrigDist <= 0)
        [peaks, locs] = findpeaks(trigger, 'minpeakheight', threshold);
    else
        [peaks, locs] = findpeaks(...
            trigger, 'minpeakheight', threshold, 'minpeakdistance', minTrigDist);
    end
    
    if (length(locs) == 0)
        % warning was produced by findpeaks
        % no events found
        return;
    end
    
    recordCount = 0;
    
    trigWindows = zeros(preSamp+postSamp + 1,size(locs,2));
    windows = zeros(preSamp + postSamp + 1, srcCount, size(locs,2));
    
    for c = 1:size(locs,2)
%         fprintf('loc (%d) of (%d)\n', c, size(locs,2));
        
        start = locs(c) - preSamp; 
        finish = locs(c) + postSamp;
        
        if (start <= 0 || finish > length(trigger))
            % skip me, pre and post extend too far
        else
            recordCount = recordCount + 1;            
            trigWindows(:,recordCount) = trigger(start:finish);

            for chanCtr = 1:srcCount
                windows(:,chanCtr,recordCount) = srcs(start:finish, chanCtr);
            end                 
        end
    end
    
    averages = sum(windows,3) / recordCount;
    trigAverage = sum(trigWindows,2) / recordCount;
    
    if (exist('figTitle'))
        if (exist('figFilename'))
            displayTriggerWindows(trigWindows, trigAverage, windows, averages, preSamp, postSamp, figTitle, figFilename);
        else
            displayTriggerWindows(trigWindows, trigAverage, windows, averages, preSamp, postSamp, figTitle);
        end
    end
end

function displayTriggerWindows(tWin, tAv, win, av, pre, post, figTitle, figFilename)
    
    x = (-1*pre):1:post;
    t = x/1.2; % TODO, assumed sample rate here, let's fix that.
    
    channels = size(win,2);
    
    screen_size = get(0, 'ScreenSize');
    fig = figure;
    set(fig, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    
    for c = 1:channels+1
        ax(c) = subplot(channels+1, 1, c);
        
        if (c == 1)
            plot(t, tWin, 'g'); hold on;
            plot(t, tAv,  'r', 'LineWidth', 2); hold off;        
            axis tight;
        else          
            temp(:,:) = win(:,c-1,:);
            plot(t, temp,        'g');

            hold on;
            
            temp3 = tAv/max(tAv) * max(av(:,(c-1)));
            
            plot(t, temp3, 'r:', 'LineWidth', 2); 
            plot(t, av(:,(c-1)), 'b', 'LineWidth', 2);

            axis tight;
            hold off;
            ylo = min(min(av(:,(c-1))), min(temp3));
            yhi = max(max(av(:,(c-1))), max(temp3));
            ylim([ylo yhi]);            
            
            switch(c)
                case 2 
                    ylabel('APB');
                case 3 
                    ylabel('FCU');
                case 4
                    ylabel('Biceps');
            end
        end
    end
    
    subplot(channels+1, 1, 1);
    title(figTitle);
    
    if (exist('figFilename'))
        print(fig, '-dmeta', figFilename);
    end
end

