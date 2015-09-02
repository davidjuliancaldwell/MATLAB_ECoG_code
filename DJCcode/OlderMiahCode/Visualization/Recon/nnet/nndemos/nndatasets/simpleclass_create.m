function [x,t] = simpleclass_create()
%
% [X,T] = <a href="matlab:doc simpleclass_create">simpleclass_create</a> creates a set of inputs X and targets T
% for a simple pattern recognition problem.
%
% This function produced the data provided by <a href="matlab:doc simpleclass_dataset">simpleclass_dataset</a>.
%
% See also SIMPLECLASS_DATASET, NPRTOOL, PATTERNNET, NNDATASETS.

% Copyright 2007-2010 The MathWorks, Inc.

centerx = [0 0 1 1];
centery = [0 1 0 1];
radius = [0.4 0.4 0.4 0.4];

numSamples = 1000;
x = zeros(2,numSamples);
t = zeros(4,numSamples);
for i=1:numSamples
  j = floor(rand*4)+1;
  t(j,i) = 1;
  angle = rand*2*pi;
  r = (rand.^0.8)*radius(j);
  x(1,i) = centerx(j) + cos(angle)*r;
  x(2,i) = centery(j) + sin(angle)*r;
end
