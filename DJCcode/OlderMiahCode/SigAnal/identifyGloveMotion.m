function [offsets, channels] = identifyGloveMotion(states, parameters, numOfGloveChannels, fs, epochRange, meanRange, codesOfInterest, type, onsetThreshold)
% function [onsets, channels] = identifyGloveOnset(states, parameters, numOfGloveChannels, fs, epochRange, meanRange, codesOfInterest, type, onsetThreshold)
%
% Changelog
%   8/10/11 - jdw - originally written
%   8/11/11 - jdw - update to use CreateSmoothGloveTrace.m
%   9/06/11 - jdw - updated to sort offsets/channels chronologically for
%     length(codesOfInterest) > 1
%
% using the data glove traces and the stimulus code values, this function
% attempts to identify the offsets at which the data glove noted a change
% in joint angles.
%
% states - the bci2k state struct
% parameters - the bci2k parameters struct
% numOfGloveChannels - for the cyberglove this is always 22
% fs - sampling frequency for states
% epochRange - a two element vector stating the number of samples before
% and after the stimulus code to include in epoch identification (e.g.
% [-600 2400])
% meanRange - a two element vector stating the number of samples before and
% after the stimulus code to use as the mean joint angle value for the data
% glove (e.g. [-600 0]).   Must be a part of the epoch range.
% codesOfInterest - a N element vector containing the stimulus codes that
% are activity epochs
% type - string of value 'peak' or 'onset'. In the case of 'peak' the
% function will identify the first peak of data glove activity within an
% epoch.  In the case of 'onset' the function will attempt to identify
% activity onset.
% onsetThreshold - a value between (0, 1), specifying the fraction of
% maximum joint flexion that is indicative of motion onset.
%
% Example use, for single finger flexion in finger twister data set:
% [of, ch] = identifyGloveMotion(states, 22, 1200, [-600 2400], [-600 0], 2, 'onset', 0.2);
%
% or 
%
% [of, ch] = identifyGloveMotion(states, 22, 1200, [-600 2400], [-600 0], 2, 'peak');

    % TODO - implement parameter checking
    
    % build dg matrix
%     dg = zeros(length(states.Cyber1), numOfGloveChannels);
% 
%     for c = 1:numOfGloveChannels
%         eval(sprintf('dg(:,%d) = double(states.Cyber%d);', c, c));
%     end
    dg = CreateSmoothGloveTrace(states, parameters, 'spline');
    
    % chunk up dg in to epochs
    offsets = [];
    for interest = codesOfInterest
        temp = getEpochs(states.StimulusCode, interest);
        offsets = [offsets; temp'];
    end
    
    offsets = sort(offsets, 'ascend');

    ixs = epochRange(1):epochRange(2);
    t = ixs/fs;

    dgEpochs = zeros(length(ixs), numOfGloveChannels, length(offsets));

    for c = 1:length(offsets)
        dgEpochs(:,:,c) = dg(ixs+offsets(c), :);
    end

    % process each epoch
    channels = zeros(size(offsets));

    for c = 1:length(offsets)
        % remove mean
        epoch = squeeze(dgEpochs(:,:,c));
        meanVals = mean(epoch(t > meanRange(1)/fs & t < meanRange(2)/fs, :), 1);
        epoch = epoch - repmat(meanVals, [size(epoch,1) 1]);

        % find the biggest glove channel after cue
        posEpoch = abs(epoch(t > 0, :));
        [val, chan] = max(max(posEpoch));

        % TODO - think of other ways to decide if no channels are
        % candidates, right now we've hardcoded in the idea that if no
        % glove channel goes more than 3 digital units away from the mean
        % then there hasn't been notable activity.  In this case we will
        % use the stimulus code offset as the activity offset.
        if (val > 3)
            channels(c) = chan;

            dgChan = posEpoch(:,chan);

            % not necessary now
%             % interpolate to make a smooth curve
%             % TODO - don't infer the sample block size, ask the user for it
%             sampleBlockSize = min(diff(find(diff([0;dgChan]) ~= 0)));
% 
%             x = 1:sampleBlockSize:length(dgChan);  
%             splinedDg = spline(x, dgChan(x), 1:length(dgChan));
% 
            % find the first peak that's half as high as the max
            % TODO - should this coefficient, 0.5 be user supplied?
            [peak, loc] = findpeaks(dgChan, 'minpeakheight', 0.3*val, 'npeaks', 1); % TODO - don't hardcode this threshold

            if (~isempty(peak))
                switch (type)
                    case 'peak'
                        offsets(c) = offsets(c) + loc;
                    case 'onset'     
                        tempLoc = loc;
                        while(tempLoc >= 1 && dgChan(tempLoc) > onsetThreshold*peak)
                            tempLoc = tempLoc - 1;
                        end
                        offsets(c) = offsets(c) + tempLoc;
                end
            else
                channels(c) = -1;
            end
        else
            channels(c) = -1;
        end
    end
end