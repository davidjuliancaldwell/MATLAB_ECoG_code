function x = nnsumr(x)
%NNSUMR Sums each row of a matrix.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use SUM(M,1).

nnerr.obs_fcn('nnsumr','Use SUM(M,1).')

%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNSUMR(X)
%   X - Matrix of column vectors: [C1 C2 ... CN].
% Returns sum of each column.
%
% SUMROW differs from SUM by leaving column vectors unchanged.
%
% EXAMPLE: x = rands(4,5)
%          y = nnsumr(x)
%
% SEE ALSO: nnsumc

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:08:11 $

[xr,xc] = size(x);
if xc > 1
  x = sum(x')';
end
