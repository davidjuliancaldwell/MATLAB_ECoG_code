function m = nnminr(m)
%NNMINR Find minimum of each row.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use MIN(M,[],1).

nnerr.obs_fcn('nnminr','Use MIN(M,[],1).')

% NNMINR(M)
%   M - matrix.
% Returns column of minimum row values.
%
% EXAMPLE: M = [1 2 3; 4 5 2]
%          nnminr(M)
%
% SEE ALSO: nnmaxr

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:08:09 $

[N,M] = size(m);

if M > 1
  m = min(m')';
end
