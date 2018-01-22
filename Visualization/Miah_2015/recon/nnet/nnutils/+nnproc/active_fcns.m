function [fcns,active] = active_fcns(fcns)

% Copyright 2010 The MathWorks, Inc.

numFcns = length(fcns);
active = false(1,numFcns);
for i=1:numFcns
  active(i) = ~fcns(i).settings.no_change;
end
fcns = fcns(active);
