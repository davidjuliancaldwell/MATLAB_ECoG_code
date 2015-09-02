function a = apply(n,param)

% Copyright 2012 The MathWorks, Inc.

min_abs_n = min(abs(n),[],1);
a = exp(bsxfun(@plus,-n.*n,min_abs_n.*min_abs_n));
suma = sum(a,1);
a = bsxfun(@rdivide,a,suma);
a(:,suma==0) = 0;

% If all elements of a net input vector are 0 the
% output is 0, for stability and compatibility with
% analytical and numerical derivatives.

