%% DJC cyberglovetiming 7/31/2014 - different method to extract cyber glove timing 
% need pr.gloveData defined from proprioception.m script ***

% define as double to use with find peaks function, invert 

pr.gloveData = double(pr.gloveData);
pr.gloveDataInvert = -pr.gloveData;

[pks,locs] = findpeaks(pr.gloveDataInvert, 'minpeakdistance', 1500, 'minpeakheight', mean(pr.gloveDataInvert));

figure
hold on
plot(pr.gloveData)
plot(locs+300,pr.gloveData(locs+300),'k^','markerfacecolor',[1 0 0])

% make vector same length as gloveData, set to zero (restcode) for all time
% points
gloveEpochStart = zeros(length(pr.gloveData),1,'uint16');

% set glove data, try adding samples of 700 to make it more like jared's
% and compare results 
gloveEpochStart(locs+300) = 1; 

%% code from jared's function to make mask 

gloveEpochMask = gloveEpochStart;
stimCode = 1;

increment = 0;
while increment < length(gloveEpochMask)-pr.fixedEpochDuration;
    increment = increment +1;
    if gloveEpochMask (increment) == stimCode;
        gloveEpochMask (increment:increment + pr.fixedEpochDuration) = stimCode;
        increment = increment + pr.fixedEpochDuration;
    end
end

responseCode = gloveEpochMask; 
pro.responseCode = responseCode;