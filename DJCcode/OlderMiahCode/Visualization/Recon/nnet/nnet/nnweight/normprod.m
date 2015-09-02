function z = normprod(w,varargin)
%NORMPROD Normalized dot product weight function.
%
%	 Weight functions apply weights to an input to get weighted inputs.
%
%	 <a href="matlab:doc normprod">normprod</a>(W,P) takes an SxR weight matrix and an RxQ input matrix and
%  returns the SxQ normalized dot product.
%
%	 Here we define a random weight matrix W and input vector P
%	 and calculate the corresponding weighted input Z.
%
%	   W = rand(4,3);
%	   P = rand(3,1);
%	   Z = <a href="matlab:doc normprod">normprod</a>(W,P)
%
%	See also DOTPROD.

% Mark Beale, 11-31-97
% Mark Hudson Beale, improvements, 01-08-2001
% Orlando De Jesus, code fix, 02-12-2002
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.11 $

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn(mfilename,w,varargin{:});
  return
end

% Apply
z = normprod.apply(w,varargin{:});
