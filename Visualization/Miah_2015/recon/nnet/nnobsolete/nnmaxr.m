function m = nnmaxr(m)
%NNMAXR Find maximum of each row.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use MAX(M,[],1).

nnerr.obs_fcn('nnmaxr','Use MAX(M,[],1).')

%  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNMAXR(M)
%   M - Matrix.
% Returns column of maximum row values.
%
% EXAMPLE: M = [1 2 3; 4 5 2]
%          maxrow(M)
%
% SEE ALSO: nnmaxr

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:08:08 $

[N,M] = size(m);

if M > 1
  m = max(m')';
end
