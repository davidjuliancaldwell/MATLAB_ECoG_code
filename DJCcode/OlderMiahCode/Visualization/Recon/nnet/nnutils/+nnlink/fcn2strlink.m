function str = fcn2strlink(fcn)

% Copyright 2010 The MathWorks, Inc.

if isempty(fcn)
  str = '(none)';
else
  str = ['''' nnlink.fcn2link(fcn) ''''];
end
