function data = formatData(data,hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:numel(data.X)
  data.X{i} = double(data.X{i});
end

for i=1:numel(data.Xi)
  data.Xi{i} = double(data.Xi{i});
end

for i=1:numel(data.Ai)
  data.Ai{i} = double(data.Ai{i});
end

if isfield(data,'T')
  for i=1:numel(data.T)
    data.T{i} = double(data.T{i});
  end
end

if isfield(data,'EW')
  for i=1:numel(data.EW)
    data.EW{i} = double(data.EW{i});
  end
end

