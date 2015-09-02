function maxFlexPoints = GetPeakCurl(states, params, stimulusCode)

load D:\Research\matlab\Experiment\Connectivity\timLeftCalib.mat


f = CreateSmoothGloveTrace(states, params, 'spline');

calibRange = AutoCalib(f);

fingerCurl = zeros(length(f),5);
% tic
% for i=1:length(f);
%     for finger = 1:5
%         pos = GetTotalAngle(f(i,:),calibRange,gloveGains,finger);
%         fingerCurl(i,finger) = pos;
%     end
%     if mod(i,1000) == 0
%         fprintf(' %i', i);
%     end
% end
% toc

fingerCurl = ConvertGloveToCurl(calibRange, gloveGains, f);


rests = getEpochs(states.StimulusCode,1);
flexs = getEpochs(states.StimulusCode,stimulusCode);

% gloveSensors = {[2 3], [5 6 7], [8 9 10], [12 13 14], [16 17 18], [1 2 3 5 6]};

maxFlexPoints = [];

for flex = flexs
    flexEnd = rests(find(rests>flex,1,'first'));
    
    try
        currentEpoch = fingerCurl(flex:flexEnd+2400,stimulusCode-1);
    catch
        continue;
    end
    
    for ceIdx = 1:size(currentEpoch,2)
        negToPosSlope = diff(diff(currentEpoch(:,ceIdx))<0)<0;
        posToNegSlope = diff(diff(currentEpoch(:,ceIdx))<0)>0;

        % try #1

        peakFlex = find(posToNegSlope);

        speeds = [];
        prePostDelay = params.SamplingRate * 0.1; % previous 100 ms
        for point = peakFlex'
            if point < prePostDelay+1 || length(currentEpoch(:,ceIdx)) - point < prePostDelay
                % not a point
                speeds = [speeds;0 0];
                continue
            end
            speeds = [speeds;mean(diff(currentEpoch(point-prePostDelay:point,ceIdx))) mean(diff(currentEpoch(point:point+prePostDelay,ceIdx)))];
        end

        peakFlex = peakFlex(speeds(:,1) > 0.00095 & speeds(:,2) < -0.00095);

%         baselineMean = mean(currentEpoch(1:400,ceIdx));
%         baselineStd = std(currentEpoch(1:400,ceIdx));

        maxFlexPoints = [maxFlexPoints;(flex + peakFlex)];

    %     fastFlexs = find();
    %%
%         plot(currentEpoch(:,ceIdx),'b');
%         hold on;
%         plot(peakFlex, currentEpoch(peakFlex,ceIdx),'r.');
    end
%     hold off;
%     plot(troughFlex, currentEpoch(troughFlex,1),'g.');
end