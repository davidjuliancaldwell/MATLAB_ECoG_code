function [n,q,ts,m] = nnsize(x)
%NNSIZE_FAST Size of neural network data.
%
%  [N,Q,TS,M] = NNSIZE_FAST(X)

% Copyright 2010 The MathWorks, Inc.

[m,ts] = size(x);
n = zeros(m,1);
if (m == 0) || (ts == 0)
  q = 0;
else
  for i=1:m
    n(i) = size(x{i,1},1);
  end
  q = size(x{1,1},2);
end
