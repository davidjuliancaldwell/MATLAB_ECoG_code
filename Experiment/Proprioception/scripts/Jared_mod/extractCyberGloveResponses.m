%% Function to extract epochs from cyberglove data

% Method: taking derivative (diff) of the "states" of the cyberglove, thresholding
% the derivative at a cutoff value, and ensuring that epochs are not too
% close together by implementing a blackout period before next epoch is
% identified (designed to help prevent false positive epoch
% identification). Once start of epoch is identified, a fixed duration
% epoch is assumed. This may be modified in the future to give acutal
% epochs based on duration of finger movement.

% Inputs are: sta = states, stimCode = code for identifying the epochs,
% rest = rest code (usually zero)

% Outputs are: responseCode = coded state info for rest and epoch.

% JDO 08/2013 - further modified for clarity/indenting DJC 07/2014 

function responseCode = extractCyberGloveResponses(sta, pr)

%[signal, sta, params] = load_bcidat('/Users/Jared/Documents/MATLAB/subjects/38e116/data/d1/38e116_fingerflex_L001/38e116_fingerflex_LS001R02'); % hardcoded input file. Will be replaced with values passed from calling script
%rest = 0;
%stimCode = 1;

%fixedEpochDuration= 800 %(fixed epoch in samples) hardcoded for now...originally 1200 for 4087bd, then 800 for abstract, originally 600 for 828260
%close all;
stimCode = 1;
%gloveData = sta.rCyber3; %currently hard coded to select the sensor to register the epochs. TODO: code to plot and then select best.

%figure;
%plot (gloveData);

gloveDerivative = diff (pr.gloveData);
%gloveEpoch = find ((diff(states.Cyber3) > 10));

%figure;
%plot (gloveDerivative);

%blackout = int64(1200) % hard coded period of time between starts of epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
%ampcutoff = 2; % derivative amplitude cutoff. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
gloveEpochStart = gloveDerivative;
for increment = 1:length(gloveDerivative);
    if gloveDerivative(increment) < pr.ampcutoff;
        gloveEpochStart(increment) = pr.restCode;
    else
        if (pr.blackout >= increment)
            if (max(gloveDerivative(1:increment-1)) >= pr.ampcutoff);
                gloveEpochStart(increment) = pr.restCode;
            end
        else
            if (max(gloveDerivative(increment-pr.blackout:increment-1)) >= pr.ampcutoff);
                gloveEpochStart(increment) = pr.restCode;
            end
        end
    end
end

%figure;
%plot (gloveEpochStart);

gloveEpochStart = [gloveEpochStart; pr.restCode]; %line to correct for length of gloveEpochStart since taking the derivative of glove data above shortened it by 1.

gloveEpochStart (gloveEpochStart ~= pr.restCode) = stimCode;
gloveEpochMask = gloveEpochStart;

increment = 0;
while increment < length(gloveEpochMask)-pr.fixedEpochDuration;
    increment = increment +1;
    if gloveEpochMask (increment) == stimCode;
        gloveEpochMask (increment:increment + pr.fixedEpochDuration) = stimCode;
        increment = increment + pr.fixedEpochDuration;
    end
end

%figure
%plot (gloveEpochMask)

%figure
%plot (gloveEpochStart)

%movementIndicies = find(gloveEpochStart > 0);
%diff (movementIndicies) %debugging to see if algorithm above is working. All indicies should be further apart than 'blackout'

figure 
plot (pr.gloveData)
hold on
epochMarkers = pr.gloveData;
epochMarkers (gloveEpochStart == 0) = NaN;
plot (epochMarkers,'+r')
%plot (gloveData(epochMarkers ~= NaN), 'x')
title('Glove Tracing with Epoch Starts');
xlabel('samples');
ylabel('glove state');
hold off


responseCode = gloveEpochMask; 
%plot (states.Cyber3);
%plot (diff(states.Cyber3));
%plot (smoothGlove(:,3));

%[gloveDerivativePeaks, gloveDerivativeLocs] = findpeaks(diff(double(states.Cyber3)));


