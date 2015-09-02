function fcn = caller(n)
%NNCALLINGFCN Returns the name of the calling function.
%
%  NNCALLINGFCN returns the name of the function calling the function
%  which called NNCALLINGFCN.
%
%  NNCALLINGFCN(1) returns the same thing.
%
%  NNCALLINGFCN(0) returns the same name returned by MFILENAME.
%
%  NNCALLINGFCN(N) with N>1, returns the name of the calling function
%  N steps up the calling stack.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, n = 1; end

s = dbstack;
if length(s) >= (n+2)
  fcn = s(n+2).file;
  if nnstring.ends(fcn,'.m')
    fcn = fcn(1:(end-2));
  end
else
  fcn = '';
end

