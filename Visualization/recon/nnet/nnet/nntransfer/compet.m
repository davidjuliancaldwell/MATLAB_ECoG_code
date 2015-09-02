function a = compet(n,varargin)
%COMPET Competitive transfer function.
%
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc compet">compet</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors with a 1 in
% each column where the corresponding column of N had its maximum value,
% and 0 elsewhere.
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc compet">compet</a>(n);
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc compet">compet</a>';
%
%	See also SOFTMAX.

% Mark Beale, 1-31-92
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2012/03/27 18:17:40 $

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = compet.apply(n);
