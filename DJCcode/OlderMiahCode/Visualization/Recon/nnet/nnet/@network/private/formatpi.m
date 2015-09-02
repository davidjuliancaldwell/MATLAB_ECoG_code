function [err,c] = formatpi(net,m,Q)
%FORMATPI Format matrix Pi.
%
%  Synopsis
%
%    [err,Pi] = formatpi(net,Pi,Q)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code dependent on this function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.8.4.4 $

err = [];
c = [];

inputSizes = nn.input_sizes(net);
totalInputSize = sum(inputSizes);
if isempty(m)
  % [] -> zeros
  c = cellmat(net.numInputs,net.numInputDelays,inputSizes,Q);
elseif (size(m,1) ~= totalInputSize)
  err = sprintf('Input states are incorrectly sized for network.\nMatrix must have %g rows.',totalInputSize);
elseif (size(m,2) ~= Q*net.numInputDelays)
  err = sprintf('Input states are incorrectly sized for network.\nMatrix must have %g columns.',Q*net.numInputDelays);
else
  % Cell -> Matrix
  c = mat2cell(m,inputSizes,zeros(1,net.numInputDelays)+Q);
end
