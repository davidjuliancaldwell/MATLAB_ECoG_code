function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:hints.numTools
  hints.subhints{i} = ...
    hints.subcalcs{i}.dataHints(net,data,hints.subhints{i});
end
