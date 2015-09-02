function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Delta
switch (hints.direction)
  case 'positive'
    delta = hints.delta;
  case 'negative'
    delta = -hints.delta;
end

[trainPerf,valPerf,testPerf,trainN,valN,testN] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
Y = hints.subcalc.y(net,data,hints.subhints);
T = gmultiply(data.originalT,data.originalTrainMask);
e1 = gsubtract(T,Y);
e1 = remove_dont_care_errors(e1);
e1 = nn_performance_fcn.normalize_error(net,e1,hints.perfParam);
e1 = gmultiply(e1,gsqrt(data.EW));
e1 = cell2mat(e1);

WB = hints.subcalc.getwb(net,hints.subhints);
numOutputs = sum(hints.output_sizes);
numWeightElements = numel(WB);
WB2 = WB;

% Numerical
jWB = zeros(numWeightElements,numOutputs*data.Q*data.TS);
for i=1:numWeightElements
  WB2(i) = WB(i) + delta;
  y2 = hints.subcalc.y(hints.subcalc.setwb(net,WB2,hints.subhints),data,hints.subhints);
  e2 = gsubtract(T,y2);
  e2 = remove_dont_care_errors(e2);
  e2 = nn_performance_fcn.normalize_error(net,e2,hints.perfParam);
  e2 = gmultiply(e2,gsqrt(data.EW));
  e2 = cell2mat(e2);
  jwbp = -(e1-e2)/delta;
  jWB(i,:) = jwbp(:)';
  WB2(i) = WB(i);
end
JE = jWB * e1(:);
JJ = jWB * jWB';

function E = remove_dont_care_errors(E)
for i=1:numel(E)
  ei = E{i};
  ei(isnan(E{i})) = 0;
  E{i} = ei;
end
