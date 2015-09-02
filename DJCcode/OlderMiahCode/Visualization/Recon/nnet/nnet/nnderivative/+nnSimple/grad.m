function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

switch hints.direction
  case {'default','backward'}
    [gWB,trainPerf,trainN] = nnSimple.bg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,{data.train.mask},...
      data.Q,data.TS,hints);
  case 'forward'
    [gWB,trainPerf,trainN] = nnSimple.fg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,{data.train.mask},...
      data.Q,data.TS,hints);
end
