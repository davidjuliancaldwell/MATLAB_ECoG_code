function [err,c] = formatai(net,m,Q)
%FORMATAI Format matrix Ai.
%
%  Synopsis
%
%    [err,Ai] = formatai(net,Ai,Q)
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

layerSizes = nn.layer_sizes(net);
totalLayerSize = sum(layerSizes);
if any(size(m) == 0)
  % [] -> zeros
  c = cellmat(net.numLayers,net.numLayerDelays,layerSizes,Q);
elseif (size(m,1) ~= totalLayerSize)
  err = sprintf('Layer states are incorrectly sized for network.\nMatrix must have %g rows.',totalLayerSize);
elseif (size(m,2) ~= Q*net.numLayerDelays)
  err = sprintf('Layer states are incorrectly sized for network.\nMatrix must have %g columns.',Q*net.numLayerDelays);
else
  % Cell -> Matrix
  c = mat2cell(m,layerSizes,zeros(1,net.numLayerDelays)+Q);
end
