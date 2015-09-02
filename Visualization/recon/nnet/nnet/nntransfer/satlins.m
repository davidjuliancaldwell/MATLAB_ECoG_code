function a = satlins(n,varargin)
%SATLINS Symmetric saturating linear transfer function.
%	
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc satlins">satlins</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors where each element
% of A is 1 where N is 1 or greater, N where N is in the interval [-1 1],
% and -1 where N is -1 or less.
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc satlins">satlins</a>(n);
%
% Here is a plot of this transfer function:
%
%   n = -5:0.01:5;
%   plot(n,<a href="matlab:doc satlins">satlins</a>(n))
%   set(gca,'dataaspectratio',[1 1 1],'xgrid','on','ygrid','on')
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc satlins">satlins</a>';
%
%	See also PURELIN, POSLIN, SATLIN.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2012/03/27 18:17:52 $

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = satlins.apply(n);
