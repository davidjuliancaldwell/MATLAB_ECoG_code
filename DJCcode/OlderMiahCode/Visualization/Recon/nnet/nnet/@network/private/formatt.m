function [err,c] = formatt(net,m,Q,TS)
%FORMATT Format matrix T.
%
%  Synopsis
%
%    [err,T] = formatt(net,T,Q)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code dependent on this function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.8.4.6 $

err = [];
c = [];

outputSizes = nn.output_sizes(net);
totalOutputSize = sum(outputSizes);
if isempty(m)
  % [] -> zeros
  c = cellmat(net.numOutputs,TS,outputSizes,Q);
elseif (size(m,1) ~= totalOutputSize)
  err = sprintf('Targets are incorrectly sized for network.\nMatrix must have %g rows.',totalOutputSize);
elseif (size(m,2) ~= Q)
  err = sprintf('Targets are incorrectly sized for network.\nMatrix must have %g columns.',Q);
else
  % Cell -> Matrix
  c = mat2cell(m,outputSizes);
end
