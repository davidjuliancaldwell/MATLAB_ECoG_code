function [z,mag,latencyMS,zI,magI,latencyIms] = zscoreCCEP(overallSignal,signalInt,t,tMin,tMax)
    
    % 4-24-2016 - DJC edit - add in tMin and tMax to enable changing this
    % trying 10-50 ms to be more in line with the literature 

    % this is for AVERAGE values here
    
    meanPre = median(overallSignal(t<0),2);
    stdPre = std(overallSignal(t<-0.005),[],2);
    signalIntAbs = abs(signalInt);
    signalIntAbsMean = median(signalIntAbs,2);
    [mag,latency] = max(signalIntAbsMean((t>tMin & t<tMax),:));
    % DJC - 3/24/2016 - change latency to be ms after stimulation
    tTemp = t(t>tMin & t<tMax);
    latencyMS = tTemp(latency); 
    
    z = (mag-meanPre)/stdPre;
    
    % this is for doing INDIVIDUAL 
    meanPre = median(overallSignal(t<0),2);
    stdPre = std(overallSignal(t<-0.005),[],2);
    signalIntAbs = abs(signalInt);
    [magI,latencyI] = max(signalIntAbs((t>tMin & t<tMax),:));
    tTemp = t(t>tMin & t<tMax);
    latencyIms = tTemp(latencyI);
    
    zI = (magI-meanPre)./stdPre;
    

end