function out1=initnw(in1,in2,in3,in4,in5,in6)
%INITNW Nguyen-Widrow layer initialization function.
%
%  <a href="matlab:doc initnw">initnw</a>(net,i) returns a network with layer i's weights and biases
%  initialized to new values.
%
%  <a href="matlab:doc initnw">initnw</a> initializes a layer's weights and biases according to the
%  Nguyen-Widrow initialization algorithm.  This algorithm chooses values
%  in order to distribute the active region of each neuron in the layer
%  randomly but evenly across the layer's input space.
%
%  <a href="matlab:doc initnw">initnw</a> is best used with layers whose transfer function has a finite
%  active input interval, such as <a href="matlab:doc tansig">tansig</a>, not an infinite active input
%  interval, such as <a href="matlab:doc purelin">purelin</a>.
%
%  Here is how to setup a network to use layer initialization functions and
%  a particular layer i to use individual weight/bias functions:
%
%    net.<a href="matlab:doc nnproperty.net_initFcn">initFcn</a> = '<a href="matlab:doc initlay">initlay</a>';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> = '<a href="matlab:doc initnw">initnw</a>';
%    net = init(net)
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{:,i}
%    net.<a href="matlab:doc nnproperty.net_LW">LW</a>{:,i}
%    net.<a href="matlab:doc nnproperty.net_b">b</a>{i}
%
%  See also INITLAY, INITWB, INIT.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.1.10.6 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Layer Initialization Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Unsupported',nn_TooFewInp); end
  if ischar(in1)
    switch in1
      case 'configure'
        switch(upper(in3))
          case 'IW'
            if in2.inputConnect(in4,in5)
              out1 = configure_input_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          case 'LW'
            if in2.layerConnect(in4,in5)
              out1 = configure_layer_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          otherwise
            error(message('nnet:NNet:UnrecWeightType'));
        end
      case 'initialize'
        switch(upper(in3))
          case 'IW'
            if in2.inputConnect(in4,in5)
              out1 = initialize_input_weight(in2,in4,in5);
            else
              out1 = [];
            end
          case 'LW'
            if in2.layerConnect(in4,in5)
              out1 = initialize_layer_weight(in2,in4,in5);
            else
              out1 = [];
            end
          case 'B'
            if in2.biasConnect(in4)
              out1 = initialize_bias(in2,in4);
            else
              out1 = [];
            end
          otherwise
            error(message('nnet:Args:UnrecValue'));
        end
      case 'info'
        out1 = INFO;
      case 'check_param'
        out1 = '';
      otherwise
        try
          out1 = eval(['INFO.' in1]);
        catch me
          nnerr.throw(['Unrecognized argument: ''' in1 ''''])
        end
    end
  else
    if (nargin < 2), nnerr.throw('Unsupported',nn_TooFewInp); end
    out1 = initialize_layer(in1,in2);
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnLayerInit(mfilename,'Nguyen-Widrow',7.0);
end

function config = configure_input_weight(net,i,j,x)
  config.range = minmax(x);
end

function config = configure_layer_weight(net,i,j,x)
  config.range = minmax(x);
end

function net = initialize_input_weight(net,i,j)
  net = initialize_layer(net,i);
end

function net = initialize_layer_weight(net,i,j)
  net = initialize_layer(net,i);
end

function net = initialize_bias(net,i)
  net = initialize_layer(net,i);
end

%% SUPPORT FUNCTIONS

function net = initialize_layer(net,i)

% Calculate source indices
inputInds = find(net.inputConnect(i,:));
numInputs = length(inputInds);
layerInds = find(net.layerConnect(i,:));
numLayers = length(layerInds);

% Get source sizes and delays
inputSizes = zeros(numInputs,1);
inputDelays = zeros(numInputs,1);
for j=1:numInputs
  inputDelays(j) = length(net.inputWeights{i,inputInds(j)}.delays);
  inputSizes(j) = net.inputWeights{i,inputInds(j)}.size(2);
end
totalInputSize = sum(inputSizes);

layerSizes = zeros(numLayers,1);
layerDelays = zeros(numInputs,1);
for j=1:numLayers
  layerDelays(j) = length(net.layerWeights{i,layerInds(j)}.delays);
  layerSizes(j) = net.layerWeights{i,layerInds(j)}.size(2);
end
totalLayerSize = sum(layerSizes);

totalSourceSize = totalInputSize + totalLayerSize;

% Calculate range indices
inputStart = cumsum([1; inputSizes]);
inputStop = cumsum(inputSizes);
layerStart = cumsum([1; layerSizes])+totalInputSize;
layerStop = cumsum(layerSizes)+totalInputSize;

% Get source ranges
range = zeros(totalSourceSize,2);
for j=1:numInputs
  irange = net.inputs{inputInds(j)}.processedRange;
  if ~isempty(irange)
    % ODJ 4/1/02 Avoid problem with delays and one column weights
    temp1=size(irange,1)*inputDelays(j);
    if temp1~= inputStop(j)-inputStart(j)-1
       temp2 = repmat(irange,inputDelays(j),1);
       range(inputStart(j):inputStop(j),:) = temp2((inputStart(j):inputStop(j))-inputStart(j)+1,:);
    else  
       range(inputStart(j):inputStop(j),:) = repmat(irange,inputDelays(j),1);
    end
  end
end
for j=1:numLayers
  lrange = feval(net.layers{layerInds(j)}.transferFcn,'output');
  if any(~isfinite(lrange))
    lrange = [max(lrange(1),-1) min(lrange(2),1)];
  end
  range(layerStart(j):layerStop(j),:) = lrange(ones(layerSizes(j),1),:);
end

% Get transferFcn info
transferFcn = net.layers{i}.transferFcn;
active = feval(transferFcn,'active');

% Check layer and sources for compatibility with Nguyen-Widrow method
ok = 1;
if ~net.biasConnect(i), ok = 0; end
if ~all(isfinite(active)), ok = 0; end
if ~strcmp(net.layers{i}.netInputFcn,'netsum'), ok = 0; end
for j=1:numInputs
  if ~strcmp(net.inputWeights{i,inputInds(j)}.weightFcn,'dotprod')
    ok = 0;
  end
end
for j=1:numLayers
  if ~strcmp(net.layerWeights{i,layerInds(j)}.weightFcn,'dotprod')
    ok = 0;
  end
end

% Use Nguyen-Widrow method if network checks out ok
if ok
  [w,b] = calcnw(range,net.layers{i}.size,active);
  
% Otherwise use RANDS
else
  sizeRows = 0;
  for j=1:numInputs
    if(net.inputWeights{i,inputInds(j)}.size(1)>sizeRows)
      sizeRows = net.inputWeights{i,inputInds(j)}.size(1);
    end
  end
  for j=1:numLayers
    if(net.layerWeights{i,layerInds(j)}.size(1)>sizeRows)
      sizeRows = net.layerWeights{i,layerInds(j)}.size(1);
    end
  end
  w = rands(sizeRows,totalSourceSize);
  if net.biasConnect(i)
    b = rands(net.layers{i}.size,1);
  end
end

for j=1:numInputs
  net.IW{i,inputInds(j)} = w(1:net.inputWeights{i,inputInds(j)}.size(1),inputStart(j):inputStop(j));
end
for j=1:numLayers
  net.LW{i,layerInds(j)} = w(1:net.layerWeights{i,layerInds(j)}.size(1),layerStart(j):layerStop(j));
end
if net.biasConnect(i)
  net.b{i} = b;
end
end

%===========================================================
function [w,b]=calcnw(pr,s,n)
%CALCNW Calculates Nugyen-Widrow initial conditions.
%
%  PR
%  S - Number of neurons.
%  N - Active region of transfer function N = [Nmin Nmax].

% Force spread across hardlim and hardlims
if (n(2) == n(1))
  n = n + [-1 1];
end

% Special case: No inputs
r = size(pr,1);
if (r == 0) || (s == 0)
  w = zeros(s,r);
  b = zeros(s,1);
  return
end

% Fix nonfinite pr
i = find(~isfinite(pr(:,1)+pr(:,2)));
pr(i,:) = repmat([0 1],length(i),1);

% Remove constant inputs
R = r;
ind = find(pr(:,1) ~= pr(:,2));
r = length(ind);
pr = pr(ind,:);

% Special case: No variable inputs
if (r == 0)
  w = zeros(s,R);
  b = zeros(s,1);
  return
end

% Nguyen-Widrow Method
% Assume inputs and net inputs range in [-1 1].
% --------------------

wMag = 0.7*s^(1/r);
wDir = randnr(s,r);
w = wMag*wDir;

if (s==1)
  b = 0;
else
  b = wMag*linspace(-1,1,s)'.*sign(w(:,1));
end

% --------------------

% Conversion of net inputs of [-1 1] to [Nmin Nmax]
x = 0.5*(n(2)-n(1));
y = 0.5*(n(2)+n(1));
w = x*w;
b = x*b+y;

% Conversion of inputs of PR to [-1 1]
x = 2./(pr(:,2)-pr(:,1));
y = 1-pr(:,2).*x;
xp = x';
b = w*y+b;
w = w.*xp(ones(1,s),:);

% Replace constant inputs
ww = w;
w = zeros(s,R);
w(:,ind) = ww;

end
%===========================================================
