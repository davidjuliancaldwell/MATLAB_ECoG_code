function net = network(varargin)
%NETWORK Create a custom neural network.
%
%  <a href="matlab:doc network">network</a> without arguments returns a new neural network with no
%  inputs, layers or outputs.
%
%  <a href="matlab:doc network">network</a>(numInputs,numLayers,biasConnect,inputConnect,layerConnect,
%  outputConnect) takes additional optional arguments and returns a neural
%  network with the following properties defined:
%    numInputs     - Number of inputs, 0.
%    numLayers     - Number of layers, 0.
%    biasConnect   - numLayers-by-1 Boolean vector, zeros.
%    inputConnect  - numLayers-by-numInputs Boolean matrix, zeros.
%    layerConnect  - numLayers-by-numLayers Boolean matrix, zeros.
%    outputConnect - 1-by-numLayers Boolean vector, zeros.
%
%  Here a network with one input and two layers is created.
%
%      net = <a href="matlab:doc network">network</a>(1,2)
%
%  Here is the code to create a 1 input, 2 layer, feed-forward network.
%  Only the first layer will have a bias.  An input weight will
%  connect to layer 1 from input 1.  A layer weight will connect
%  to layer 2 from layer 1.  Layer 2 will be a network output.
%
%    net = <a href="matlab:doc network">network</a>(1,2,[1;0],[1; 0],[0 0; 1 0],[0 1])
%
%  We can then see the properties of subobjects as follows:
%
%    net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{1}
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}, net.<a href="matlab:doc nnproperty.net_layers">layers</a>{2}
%    net.<a href="matlab:doc nnproperty.net_biases">biases</a>{1}
%    net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{1,1}, net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{2,1}
%    net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{2}
%
%  We can get the weight matrices and bias vector as follows:
%
%    net.<a href="matlab:doc nnproperty.net_IW">IW</a>{1,1}, net.<a href="matlab:doc nnproperty.net_IW">IW</a>{2,1}, net.<a href="matlab:doc nnproperty.net_b">b</a>{1}
%
%  We can alter the properties of any of these subobjects.  Here
%  we change the transfer functions of both layers:
%
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = 'tansig';
%    net.<a href="matlab:doc nnproperty.net_layers">layers</a>{2}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = 'logsig';
%
%  Here we change the number of elements in input 1 to 2, by setting
%  each element's range:
%
%    net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{1}.<a href="matlab:doc nnproperty.input_range">range</a> = [0 1; -1 1];
%
%  Next we can simulate the network for a 2-element input vector:
%
%    p = [0.5; -0.1];
%    y = net(p)
%
%  See also INIT, REVERT, SIM, ADAPT, TRAIN, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.9.4.13 $ $Date: 2012/03/27 18:08:09 $

if (nargin == 1)
  in1 = varargin{1};
  if isa(in1,'struct')
    net = class(in1,'network');
  elseif isa(in1,'network')
    net = in1;
  else
    net = new_network(in1);
  end
else
  net = new_network(varargin{:});
end

function net = new_network(numInputs,numLayers,biasConnect,inputConnect, ...
  layerConnect,outputConnect,ignore) %#ok<INUSD>

% Defaults
if nargin < 1, numInputs = 0; end
if nargin < 2, numLayers = 0; end
if nargin < 3, biasConnect = false(numLayers,1); end
if nargin < 4, inputConnect = false(numLayers,numInputs); end
if nargin < 5, layerConnect = false(numLayers,numLayers); end
if nargin < 6, outputConnect = false(1,numLayers); end

% Checking
% TODO - Error checking

% NETWORK PROPERTIES
% Note: "Param" and "Config" properties in NETWORK and subobject
% (nnetInput, nnetOutput, nnetLayer, nnetWeight, nnetBias) properties must
% always occur directly after their associated "Fcn" properties for
% NN_STRUCT2OBJECT conversions to work properly.

% Version
net.version = '8';

% Basics
net.name = 'Custom Neural Network';
net.efficiency.cacheDelayedInputs = true;
net.efficiency.flattenTime = true;
net.efficiency.memoryReduction = 1;
net.userdata.note = 'Put your custom network information here.';

% Sizes
net.numInputs = 0;
net.numLayers = 0;
net.numOutputs = 0;
net.numInputDelays = 0;
net.numLayerDelays = 0;
net.numFeedbackDelays = 0;
net.numWeightElements = 0;
net.sampleTime = 1;

% Connections
net.biasConnect = false(0,1);
net.inputConnect = false(0,0);
net.layerConnect = false(0,0);
net.outputConnect = false(1,0);

% Subobjects
net.inputs = cell(0,1);
net.layers = cell(0,1);
net.biases = cell(0,1);
net.outputs = cell(1,0);
net.inputWeights = cell(0,0);
net.layerWeights = cell(0,0);

% Functions and parameters
net.adaptFcn = '';
net.adaptParam = struct;
net.divideFcn = '';
net.divideParam = struct;
net.divideMode = 'sample';
net.initFcn = 'initlay';
net.performFcn = 'mse';
net.performParam = mse('defaultParam');
net.plotFcns = cell(1,0);
net.plotParams = cell(1,0);
net.derivFcn = 'defaultderiv';
net.trainFcn = '';
net.trainParam = nnetParam;

% Weight & bias values
net.IW = cell(0,0);
net.LW = cell(0,0);
net.b = cell(0,1);

% Hidden properties
net.revert.IW = {};
net.revert.LW = {};
net.revert.b = {};

% Obsolete properties
% NNET 6.0 Compatibility
net.gradientFcn = ''; % Obsolete
net.gradientParam = struct; % Obsolete

% CLASS
net = class(net,'network');

% ARCHITECTURE
net = setnet(net,'numInputs',numInputs);
net = setnet(net,'numLayers',numLayers);
net = setnet(net,'biasConnect',biasConnect);
net = setnet(net,'inputConnect',inputConnect);
net = setnet(net,'layerConnect',layerConnect);
net = setnet(net,'outputConnect',outputConnect);

function net = setnet(net,field,value)
subscripts.type = '.';
subscripts.subs = field;
net = subsasgn(net,subscripts,value);
