function y = y(net,x,xi,ai,Q)

% Copyright 2012 The MathWorks, Inc.

TS = size(x,2);

if nargin < 3, xi = {}; end
if nargin < 4, ai = {}; end

if nargin < 5
  if ~isempty(x)
    Q = size(x{1},2);
  elseif (nargin >= 3) && ~isempty(xi)
    Q = size(xi{1},2);
  elseif (nargin >= 4) && ~isempty(ai)
    Q = size(ai{1},2);
  else
    Q = 0;
  end
end

if nargin < 3
  xi = cell(net.numInputs,net.numInputDelays);
  for i=1:net.numInputs
    xi(i,:) = {zeros(net.inputs{i}.size,Q)};
  end
end

if nargin < 4
  ai = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    ai(i,:) = {zeros(net.layers{i}.size,Q)};
  end
end

data.X = x;
data.Xi = xi;
data.Ai = ai;
data.Q = Q;
data.TS = TS;
data.Pc = {};
data.Pd = {};

net = struct(net);
net.trainFcn = ''; % Disable training related setup
calcMode = nncalc.defaultMode(net);
[calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
[calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints,false);
y = calcLib.y(calcNet);
