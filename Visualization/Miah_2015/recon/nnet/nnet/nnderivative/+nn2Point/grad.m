function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Delta
switch (hints.direction)
  case 'positive'
    delta = hints.delta;
  case 'negative'
    delta = -hints.delta;
end

subHints = hints.subhints;
subSetWB = hints.subcalc.setwb;
subTrainPerf = hints.subcalc.trainPerf;
[trainPerf,trainN] = subTrainPerf(net,data,subHints);
WB = hints.subcalc.getwb(net,hints.subhints);
numWeightElements = numel(WB);
WB2 = WB;

% Positive 2-point
gWB = zeros(numWeightElements,1);
for i=1:numWeightElements
  
  WB2(i) = WB(i) + delta;
  [perf2,trainN] = subTrainPerf(subSetWB(net,WB2,subHints),data,subHints);
  gWB(i) = (trainPerf - perf2)/delta;
    
  WB2(i) = WB(i);
end
