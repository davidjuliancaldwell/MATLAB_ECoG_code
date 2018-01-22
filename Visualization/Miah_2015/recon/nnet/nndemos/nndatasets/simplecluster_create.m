function x = simplecluster_create()
%
% X = <a href="matlab:doc simplecluster_create">simplecluster_create</a> creates a set of inputs X for a simple
% clustering problem.
%
% This function produced the data provided by <a href="matlab:doc simplecluster_dataset">simplecluster_dataset</a>.
%
% See also SIMPLECLUSTER_DATASET, NCTOOL, SELFORGMAP, NNDATASETS.

% Copyright 2007-2010 The MathWorks, Inc.

centerx = [0 0 1 1];
centery = [0 1 0 1];
radius = [0.7 0.6 0.3 0.7];

numSamples = 1000;
x = zeros(2,numSamples);
for i=1:numSamples
  j = floor(rand*4)+1;
  angle = rand*2*pi;
  r = (rand.^0.8)*radius(j);
  x(1,i) = centerx(j) + cos(angle)*r;
  x(2,i) = centery(j) + sin(angle)*r;
end
