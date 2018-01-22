function [flag,inputFlags,outputFlags] = isconfigured(net)
%ISCONFIGURED Are network inputs and outputs configured?
%
% <a href="matlab:doc isconfigured">isconfigured</a>(NET) return true if all inputs and outputs are configured,
% i.e. have non-zero sizes.
%
% [FLAG,INPUTFLAGS,OUTPUTFLAGS] = <a href="matlab:doc isconfigured">isconfigured</a>(NET) returns two additional
% boolean vectors, containing true or false respectively indicating
% whether each network input or output is configured.
%
% For instance, here are the flags returned for a new network before and
% after being configured:
%
%   net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>;
%   [flag,inputFlags,outputFlags] = <a href="matlab:doc isconfigured">isconfigured</a>(net)
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc configure">configure</a>(net,x,t);
%   [flag,inputFlags,outputFlags] = <a href="matlab:doc isconfigured">isconfigured</a>(net)
%
% See also CONFIGURE, UNCONFIGURE.

% Copyright 2010 The MathWorks, Inc.

inputFlags = false(1,net.numInputs);
outputFlags = false(1,net.numOutputs);
for i=1:net.numInputs
  inputFlags(i) = (net.inputs{1}.size ~= 0);
end
output2layer = find(net.outputConnect);
for i=1:net.numOutputs
  ii = output2layer(i);
  outputFlags(i) = (net.outputs{ii}.size ~= 0);
end
flag = all([inputFlags outputFlags]);
