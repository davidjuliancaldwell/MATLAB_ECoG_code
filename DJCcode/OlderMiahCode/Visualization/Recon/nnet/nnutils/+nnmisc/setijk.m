function x = setijk(x,v,i,j,k)
%SETIJK Set subarray of matrix or cell array.

% Copyright 2010 The MathWorks, Inc.

if nargin == 3
  x(i) = v;
elseif nargin == 4
  x(i,j) = v;
elseif nargin == 5
  x(i,j,k) = v;
end
