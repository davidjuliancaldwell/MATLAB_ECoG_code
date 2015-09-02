function data2 = formatData(data1,hints)

% Copyright 2012 The MathWorks, Inc.

data2 = hints.subcalc.formatData(data1,hints.subhints);
data2.originalT = data1.T;
data2.originalTrainMask = data1.train.mask;
