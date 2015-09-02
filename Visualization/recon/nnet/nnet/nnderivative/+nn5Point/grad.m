function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

delta = hints.delta;

subHints = hints.subhints;
subSetWB = hints.subcalc.setwb;
subTrainPerf = hints.subcalc.trainPerf;

[trainPerf,trainN] = subTrainPerf(net,data,subHints);
WB = hints.subcalc.getwb(net,hints.subhints);
WB2 = WB;

numWeightElements = numel(WB);
gWB = zeros(numWeightElements,1);
for i=1:numWeightElements
    WB2(i) = WB(i)-2*delta;
    [perf1,trainN] = subTrainPerf(subSetWB(net,WB2,subHints),data,subHints);
    WB2(i) = WB(i)-delta;
    [perf2,trainN] = subTrainPerf(subSetWB(net,WB2,subHints),data,subHints);
    WB2(i) = WB(i)+delta;
    [perf3,trainN] = subTrainPerf(subSetWB(net,WB2,subHints),data,subHints);
    WB2(i) = WB(i)+2*delta;
    [perf4,trainN] = subTrainPerf(subSetWB(net,WB2,subHints),data,subHints);
    WB2(i) = WB(i);
    gWB(i) = (perf4 - 8*perf3 + 8*perf2 - perf1) / (12*delta);
end
