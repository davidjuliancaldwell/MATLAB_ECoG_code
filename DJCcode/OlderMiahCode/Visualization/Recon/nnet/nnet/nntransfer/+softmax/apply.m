function a = apply(n,param)

% Copyright 2012 The MathWorks, Inc.

nmax = max(n,[],1);
n = bsxfun(@minus,n,nmax);

numer = exp(n);
denom = sum(numer,1); 
denom(denom == 0) = 1;
a = bsxfun(@rdivide,numer,denom);

% Normalizing N by subtracting the maximum value in each
% vector improves numerical accuracy.

% Calculating numerator and denominator separately
% avoids a "Rank deficient" warning in some cases.
% Example - softmax([0 inf; -1 1])

