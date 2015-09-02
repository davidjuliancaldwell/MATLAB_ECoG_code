function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.

settings.no_change = true;
settings.xrows = size(x,1);
settings.yrows = size(x,1);
settings.classRatios = sum(compet(x),2);

y = x;
