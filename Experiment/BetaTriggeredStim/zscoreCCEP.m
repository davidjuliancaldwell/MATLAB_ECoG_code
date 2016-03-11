function [z,mag,latency] = zscoreCCEP(overallSignal,signalInt,t)

    meanPre = median(overallSignal(t<0),2);
    stdPre = std(overallSignal(t<-0.005),[],2);
    signalIntAbs = abs(signalInt);
    signalIntAbsMean = median(signalIntAbs,2);
    [mag,latency] = max(signalIntAbsMean((t>0.01 & t<0.03),:));
    z = (mag-meanPre)/stdPre;

end