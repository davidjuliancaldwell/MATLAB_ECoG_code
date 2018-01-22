function [s,n] = sumabs(x)
%SUMABS Sum of absolute elements of a matrix or matrices.
%
%  [S,N] = <a href="matlab:doc sumabs">sumabs</a>(X) returns S the sum of all squared finite elements in M,
%  and the number of finite elements N.  M may be a numeric matrix or a
%  cell array of numeric matrices.
%
%  For example:
%
%    s = <a href="matlab:doc sumabs">sumabs</a>([1 2;3 4])
%    [s,n] = <a href="matlab:doc sumabs">sumabs</a>({[1 2; NaN 4], [4 5; 2 3]})
%
%  See also MEANABS, SUMSQR, MEANSQR.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $  $Date: 2011/02/28 01:27:38 $

if nargin<1,error(message('nnet:Args:NotEnough'));end

if isreal(x)
  notFinite = find(~isfinite(x));
  x(notFinite) = 0;
  s = abs(x);
  for i=1:ndims(s)
    s = sum(s);
  end
  n = numel(x) - length(notFinite);
elseif iscell(x)
  s = 0;
  n = 0;
  for i=1:numel(x)
    [si,ni] = sumabs(x{i});
    s = s + si;
    n = n + ni;
  end
else
  error(message('nnet:NNData:NotNumOrCellNum'))
end
