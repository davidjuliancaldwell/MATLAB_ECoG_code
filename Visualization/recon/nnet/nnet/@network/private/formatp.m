function [err,c] = formatp(net,m,Q)
%FORMATP Format matrix  P.
%
%  Synopsis
%
%    [err,P] = formatp(net,P,Q)
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

% Check number of rows
input_sizes = nn.input_sizes(net);
totalInputSize = sum(input_sizes);
if (size(m,1) ~= totalInputSize)
  err = sprintf('Inputs are incorrectly sized for network.\nMatrix must have %g rows.',totalInputSize);
elseif (size(m,2) ~= Q)
  err = sprintf('Inputs are incorrectly sized.\nMatrix must have %g columns.',Q);
else
  % Cell -> Matrix
  c = mat2cell(m,input_sizes);
end
