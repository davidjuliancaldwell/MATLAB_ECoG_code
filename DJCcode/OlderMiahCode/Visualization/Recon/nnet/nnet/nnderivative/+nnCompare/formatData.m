function data = formatData(data,hints)

% Copyright 2012 The MathWorks, Inc.

data1 = data;

data = struct;
data.subdata = cell(1,hints.numTools);
for i=1:hints.numTools
  data.subdata{i} = hints.subcalcs{i}.formatData(data1,hints.subhints{i});
end
