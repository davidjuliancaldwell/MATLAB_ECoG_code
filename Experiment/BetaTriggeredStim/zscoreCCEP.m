function [z,mag,latencyMS,zI,magI,latencyIms] = zscoreCCEP(overallSignal,signalInt,t)

    % this is for AVERAGE values here
    meanPre = median(overallSignal(t<0),2);
    stdPre = std(overallSignal(t<-0.005),[],2);
    signalIntAbs = abs(signalInt);
    signalIntAbsMean = median(signalIntAbs,2);
    [mag,latency] = max(signalIntAbsMean((t>0.01 & t<0.03),:));
    % DJC - 3/24/2016 - change latency to be ms after stimulation
    tTemp = t(t>0.01 & t<0.03);
    latencyMS = tTemp(latency); 
    
    z = (mag-meanPre)/stdPre;
    
    % this is for doing INDIVIDUAL 
    meanPre = median(overallSignal(t<0),2);
    stdPre = std(overallSignal(t<-0.005),[],2);
    signalIntAbs = abs(signalInt);
    [magI,latencyI] = max(signalIntAbs((t>0.01 & t<0.03),:));
    tTemp = t(t>0.01 & t<0.03);
    latencyIms = tTemp(latencyI);
    
    zI = (magI-meanPre)./stdPre;
    

end