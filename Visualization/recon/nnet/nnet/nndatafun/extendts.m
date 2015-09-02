function x = extendts(x,ts,v)
%EXTENDTS Extends time series data to a given number of timesteps.
%
%  <a href="matlab:doc extendts">extendts</a>(X,TS,VALUE) returns X extended to timesteps TS, if TS > number
%  of timesteps in X.  If TS < number of timesteps in X, then X is
%  truncated to TS timesteps.  The matrices used to extend X are filled
%  with the scalar VALUE.
%
%  <a href="matlab:doc extendts">extendts</a>(X,TS) extends X with random matrices.
%
%  For example, here X is defined as 20 timesteps of 4 samples of
%  5 elements each, filled with random values.  It is then extended
%  out to 25 timesteps, with the additional 5 timesteps set to zeros.
%
%    x = <a href="matlab:doc nndata">nndata</a>(5,4,20);
%    x = <a href="matlab:doc extendts">extendts</a>(x,25,0);
%
%  See also NNDATA.

% Copyright 2010 The MathWorks, Inc.

nnassert.minargs(nargin,2);
if (nargin < 3)
  v = [];
elseif ~isempty(v)
  nntype.num_scalar('check',v,'VALUE')
end

[xN,xQ,xTS] = nnfast.nnsize(x);
if (xTS > ts)
  x = x(:,1:ts);
elseif (xTS > ts)
  x = [x nndata(xN,xQ,xTS-ts,v)];
end
   
