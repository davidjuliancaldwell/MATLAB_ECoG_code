function hints = codeHints(hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:hints.numTools
  hints.subhints{i} = ...
    hints.subcalcs{i}.codeHints(hints.subhints{i});
end
