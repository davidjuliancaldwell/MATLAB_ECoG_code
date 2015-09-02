function data = formatData(data1,hints)

% Simulation Data
data.X = full(cell2mat(data1.X));
data.Xi = full(cell2mat(data1.Xi));
data.Pc = full(cell2mat(data1.Pc));
data.Pd = []; % TODO - check if c supports this
data.Ai = full(cell2mat(data1.Ai));

data.Q = data1.Q;
data.TS = data1.TS;

% Performance Data
if isfield(data1,'T')
  data.T = full(cell2mat(data1.T));
  data.EW = full(cell2mat(data1.EW));
  if isfield (data1,'train')
    data.masks = cell2mat([data1.train.mask data1.val.mask data1.test.mask]);
    data.trainMask = cell2mat(data1.train.mask);
  end
end