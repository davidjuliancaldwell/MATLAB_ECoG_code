function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

subHints = hints.subhints;
subGetWB = hints.subcalc.getwb;
subSetWB = hints.subcalc.setwb;
subTrainPerf = hints.subcalc.trainPerf;

[gWBsub,trainPerf,trainN] = hints.subcalc.grad(net,data,subHints);

gWB = net_wb_deriv(net,subGetWB,subSetWB,subTrainPerf,subHints,data,gWBsub);

if (nargout < 3) && hints.perfNorm
  gWB = gWB / max(1,trainN);
  trainPerf = trainPerf / trainN;
end

function d = net_wb_deriv(net,subGetWB,subSetWB,subTrainPerf,subHints,data,gWBsub)
wb = subGetWB(net,subHints);
d = zeros(size(wb));
num = numel(wb);
for i=1:num
  fprintf('%g ',i);
  if rem(i,10)==0, disp(' '); end
  fcn = net_wb_deriv_wrapper('setup',net,data,i,wb,subSetWB,subTrainPerf,subHints);
  d(i) = -nntest.numderivn(fcn,wb(i),-gWBsub(i));
end

function y = net_wb_deriv_wrapper(x,n,d,i,wb,sub1,sub2,sub3)
persistent net;
persistent WB;
persistent data;
persistent index;
persistent subSetWB;
persistent subTrainPerf;
persistent subHints;
if ischar(x) && strcmp(x,'setup')
  net = n;
  data = d;
  index = i;
  subSetWB = sub1;
  subTrainPerf = sub2;
  subHints = sub3;
  WB = wb;
  y = @net_wb_deriv_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    WB2 = WB;
    WB2(index) = x(i);
    net2 = subSetWB(net,WB2,subHints);
    [y(i),~] = subTrainPerf(net2,data,subHints);
  end
end
