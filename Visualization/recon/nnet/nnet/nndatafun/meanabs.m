function [m,n] = meanabs(x)
%MEANABS Mean of absolute elements of a matrix or matrices.
%
%  [M,N] = <a href="matlab:doc meanabs">meanabs</a>(X) returns the mean M of all absolute finite elements
%  in X, and the number of finite elements N. X may be a numeric matrix
%  or a cell array of numeric matrices.
%
%  If X contains no finite values, the mean returned is 0.
%
%  For example:
%
%    m = <a href="matlab:doc meanabs">meanabs</a>([1 2;3 4])
%    [m,n] = <a href="matlab:doc meanabs">meanabs</a>({[1 2; NaN 4], [4 5; 2 3]})
%
%  See also SUMABS, MEANSQR, SUMSQR.

% Copyright 2010 The MathWorks, Inc.

[s,n] = sumabs(x);
if n == 0
  m = 0;
else
  m = s/n;
end
