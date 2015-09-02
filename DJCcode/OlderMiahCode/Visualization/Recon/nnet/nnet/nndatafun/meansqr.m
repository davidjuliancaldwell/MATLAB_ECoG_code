function [m,n] = meansqr(x)
%MEANSQR Mean of squared elements of a matrix or matrices.
%
%  [M,N] = MEANSQR(X) returns the mean M of all squared finite elements
%  in X, and the number of finite elements N. X may be a numeric matrix
%  or a cell array of numeric matrices.
%
%  If X contains no finite values, the mean returned is 0.
%
%  For example:
%
%    m = <a href="matlab:doc meansqr">meansqr</a>([1 2;3 4])
%    [m,n] = <a href="matlab:doc meansqr">meansqr</a>({[1 2; NaN 4], [4 5; 2 3]})
%
%  See also SUMSQR, SUMABS, MEANABS.

% Copyright 2010 The MathWorks, Inc.

[s,n] = sumsqr(x);
if n == 0
  m = 0;
else
  m = s/n;
end
