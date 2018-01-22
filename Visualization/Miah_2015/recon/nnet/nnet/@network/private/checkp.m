function [err] = checkp(net,p,Q,TS)
%CHECKP Check P dimensions.
%
%  Synopsis
%
%    [err] = checkp(net,P,Q,TS)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code dependent on this function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.8.4.4 $

inputSizes = nn.input_sizes(net);
err = cellmat_checksizes(p,net.numInputs,TS,inputSizes,Q);
if ~isempty(err), err = ['P: ' err]; end
