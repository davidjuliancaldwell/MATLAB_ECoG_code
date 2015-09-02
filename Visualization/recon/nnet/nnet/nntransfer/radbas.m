function a = radbas(n,varargin)
%RADBAS Radial basis transfer function.
%	
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc radbas">radbas</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors, where each value
% of N in the interval [-inf inf] is squashed with a bell-shaped function
% centered at 0 into the interval [0 1].
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc radbas">radbas</a>(n);
%
% Here is a plot of this transfer function:
%
%   n = -5:0.01:5;
%   plot(n,<a href="matlab:doc radbas">radbas</a>(n))
%   set(gca,'dataaspectratio',[1 1 1],'xgrid','on','ygrid','on')
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc radbas">radbas</a>';
%
%	See also TRIBAS.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.8 $  $Date: 2012/03/27 18:17:49 $

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = radbas.apply(n);
