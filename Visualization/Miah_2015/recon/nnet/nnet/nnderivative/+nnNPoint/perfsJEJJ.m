function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,valPerf,testPerf,trainN,valN,testN] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
Y = hints.subcalc.y(net,data,hints.subhints);
T = gmultiply(data.originalT,data.originalTrainMask);

WB = hints.subcalc.getwb(net,hints.subhints);
numOutputs = sum(hints.output_sizes);
numWeightElements = numel(WB);

jWB = zeros(numWeightElements,numOutputs*data.Q*data.TS);
delta = 1e-7;
WB = hints.subcalc.getwb(net,hints.subhints);
WB2 = WB;
e0 = gsubtract(T,Y);
e0 = remove_dont_care_errors(e0);
e0 = nn_performance_fcn.normalize_error(net,e0,hints.perfParam);
e0 = gmultiply(e0,gsqrt(data.EW));
e0 = cell2mat(e0);

for i=1:numWeightElements
  WB2(i) = WB(i)+2*delta;
  y1 = hints.subcalc.y(hints.subcalc.setwb(net,WB2,hints.subhints),data,hints.subhints);
  e1 = gsubtract(T,y1);
  e1 = remove_dont_care_errors(e1);
  e1 = nn_performance_fcn.normalize_error(net,e1,hints.perfParam);
  e1 = gmultiply(e1,gsqrt(data.EW));
  e1 = cell2mat(e1);

  WB2(i) = WB(i)+delta;
  y2 = hints.subcalc.y(hints.subcalc.setwb(net,WB2,hints.subhints),data,hints.subhints);
  e2 = gsubtract(T,y2);
  e2 = remove_dont_care_errors(e2);
  e2 = nn_performance_fcn.normalize_error(net,e2,hints.perfParam);
  e2 = gmultiply(e2,gsqrt(data.EW));
  e2 = cell2mat(e2);

  WB2(i) = WB(i)-delta;
  y3 = hints.subcalc.y(hints.subcalc.setwb(net,WB2,hints.subhints),data,hints.subhints);
  e3 = gsubtract(T,y3);
  e3 = remove_dont_care_errors(e3);
  e3 = nn_performance_fcn.normalize_error(net,e3,hints.perfParam);
  e3 = gmultiply(e3,gsqrt(data.EW));
  e3 = cell2mat(e3);

  WB2(i) = WB(i)-2*delta;
  y4 = hints.subcalc.y(hints.subcalc.setwb(net,WB2,hints.subhints),data,hints.subhints);
  e4 = gsubtract(T,y4);
  e4 = remove_dont_care_errors(e4);
  e4 = nn_performance_fcn.normalize_error(net,e4,hints.perfParam);
  e4 = gmultiply(e4,gsqrt(data.EW));
  e4 = cell2mat(e4);
  jwb = -((e1 - 8*e2 + 8*e3 - e4)) / (12*delta);
  jWB(i,:) = jwb(:)';

  WB2(i) = WB(i);
end

JE = jWB * e0(:);
JJ = jWB * jWB';

function E = remove_dont_care_errors(E)
for i=1:numel(E)
  ei = E{i};
  ei(isnan(E{i})) = 0;
  E{i} = ei;
end
