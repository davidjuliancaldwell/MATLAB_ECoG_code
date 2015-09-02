function z = dotprod(w,varargin)
%DOTPROD Dot product weight function.
%
%	 Weight functions apply weights to an input to get weighted inputs.
%
%  <a href="matlab:doc dotprod">dotprod</a>(W,P) returns the dot product W * P of a weight matrix W and
%  an input P.
%
%	 Here we define a random weight matrix W and input vector P
%	 and calculate the corresponding weighted input Z.
%
%	   W = rand(4,3);
%	   P = rand(3,1);
%	   Z = <a href="matlab:doc dotprod">dotprod</a>(W,P)
%
%	See also SIM, DDOTPROD, DIST, NEGDIST, NORMPROD.

% Mark Beale, 11-31-97
% Mark Hudson Beale, improvements, 01-08-2001
% Orlando De Jesus, code fix, 02-12-2002
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.6.8 $

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn(mfilename,w,varargin{:});
  return
end

% Apply
z = dotprod.apply(w,varargin{:});
