function [trainV,valV,testV] = separate_data(net,data)

% Copyright 2010 The MathWorks, Inc.

trainV.X = data.X;
trainV.Xi = data.Xi;
trainV.Pd = data.Pd;
trainV.Ai = data.Ai;
trainV.T = data.T;
trainV.Q = data.Q;
trainV.TS = data.TS;
if data.train.masked
  trainV.T = gmultiply(trainV.T,data.train.mask);
end
trainV = select_sample_indices(trainV);
trainV = define_tl(net,trainV);

if data.val.enabled
  valV.X = data.X;
  valV.Xi = data.Xi;
  valV.Pd = data.Pd;
  valV.Ai = data.Ai;
  valV.T = gmultiply(data.T,data.val.mask);
  valV.Q = data.Q;
  valV.TS = data.TS;
  valV = select_sample_indices(valV);
  valV = define_tl(net,valV);
else
  valV = [];
end

if data.test.enabled
  testV.X = data.X;
  testV.Xi = data.Xi;
  testV.Pd = data.Pd;
  testV.Ai = data.Ai;
  testV.T = gmultiply(data.T,data.test.mask);
  testV.Q = data.Q;
  testV.TS = data.TS;
  testV = select_sample_indices(testV);
  testV = define_tl(net,testV);
else
  valV = [];
end

function V = define_tl(net,V)

V.Tl = cell(net.numLayers,V.TS);
V.Tl(net.outputConnect,:) = V.T;

function V = select_sample_indices(V)

fs = isfinite(V.T{1});
for i=2:numel(V.T)
  fs = fs || isfinite(V.T{i});
end
fs = sum(fs,1) > 0;
V.indices = find(fs);
Q = length(V.indices);
if Q < V.Q
  V.X = nnfast.getsamples(V.X,V.indices);
  V.Xi = nnfast.getsamples(V.Xi,V.indices);
  V.Pd = nnfast.getsamples(V.Pd,V.indices);
  V.Ai = nnfast.getsamples(V.Ai,V.indices);
  V.T = nnfast.getsamples(V.T,V.indices);
  V.Q = Q;
end
