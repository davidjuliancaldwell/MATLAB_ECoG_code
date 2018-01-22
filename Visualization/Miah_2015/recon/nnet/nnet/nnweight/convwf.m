function z = convwf(w,varargin)
%CONVWF Convolution weight function.
%
%	 Weight functions apply weights to an input to get weighted inputs.
%
%  <a href="matlab:doc convwf">convwf</a>(W,P) returns the convolution of a weight matrix W and
%  an input P.
%
%	 Here we define a random weight matrix W and input vector P
%	 and calculate the corresponding weighted input Z.
%
%	   W = rand(4,1);
%	   P = rand(8,1);
%	   Z = <a href="matlab:doc convwf">convwf</a>(W,P)
%
%	See also DOTPROD, NEGDIST, NORMPROD, SCALPROD.

% Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn(mfilename,w,varargin{:});
  return
end

% Apply
p = varargin{1};
z = convwf.apply(w,varargin{:});
