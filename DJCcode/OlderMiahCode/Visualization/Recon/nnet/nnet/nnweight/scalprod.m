function z = scalprod(w,varargin)
%SCALPROD Scalar product weight function.
%
%	 Weight functions apply weights to an input to get weighted inputs.
%
%	 <a href="matlab:doc scalprod">scalprod</a>(W,P) takes an 1x1 scalar weight and an RxQ input matrix and
%  returns the RxQ product of the weight and inputs.
%
%  Here we define a random weight matrix W and input vector P
%  and calculate the corresponding weighted input Z.
%
%	   W = rand(1,1);
%	   P = rand(3,1);
%	   Z = <a href="matlab:doc scalprod">scalprod</a>(W,P)
%
%	See also DOTPROD, SIM, DIST, NEGDIST, NORMPROD.

% Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn(mfilename,w,varargin{:});
  return
end

% Apply
z = scalprod.apply(w,varargin{:});
