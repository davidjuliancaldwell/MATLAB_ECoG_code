function slice = split_data(data,qq)

% Copyright 2012 The MathWorks, Inc.

slice.X = nnfast.getsamples(data.X,qq);

slice.Xi = nnfast.getsamples(data.Xi,qq);

if isfield(data,'Pc')
  slice.Pc = nnfast.getsamples(data.Pc,qq);
end

if isfield(data,'Pd')
  slice.Pd = nnfast.getsamples(data.Pd,qq);
end

slice.Ai = nnfast.getsamples(data.Ai,qq);

slice.Q = numel(qq);

slice.TS = data.TS;

if isfield(data,'T')
  slice.T = nnfast.getsamples(data.T,qq);
end

if isfield(data,'EW')
  slice.EW = cell(size(data.EW));
  for j=1:numel(data.EW)
    ew = data.EW{j};
    if size(ew,2) == data.Q, ew = ew(:,qq); end
    slice.EW{j} = ew;
  end
end

if isfield(data,'train')
  slice.train.enabled = data.train.enabled;
  slice.train.mask = nnfast.getsamples(data.train.mask,qq);
end

if isfield(data,'val')
  slice.val.enabled = data.val.enabled;
  slice.val.mask = nnfast.getsamples(data.val.mask,qq);
end

if isfield(data,'test')
  slice.test.enabled = data.test.enabled;
  slice.test.mask = nnfast.getsamples(data.test.mask,qq);
end
