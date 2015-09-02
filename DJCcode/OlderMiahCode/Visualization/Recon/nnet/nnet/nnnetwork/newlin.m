function out1 = newlin(varargin)
%NEWLIN Create a linear layer.
%
%  Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%  The recommended function is <a href="matlab:doc linearlayer">linearlayer</a>.
%
%  Syntax
%
%    net = newlin(P,S,ID,LR)
%    net = newlin(P,T,ID,LR)
%
%  Description
%
%    Linear layers are often used as adaptive filters
%    for signal processing and prediction.
%
%    NEWLIN(P,S,ID,LR) takes these arguments,
%      P  - RxQ matrix of Q representative input vectors.
%      S  - Number of elements in the output vector.
%      ID - Input delay vector, default = [0].
%      LR - Learning rate, default = 0.01;
%    and returns a new linear layer.
%
%    NEWLIN(P,T,ID,LR) takes the same arguments except for
%      T - SxQ2 matrix of Q2 representative S-element output vectors.
%
%    NET = NEWLIN(PR,S,0,P) takes an alternate argument,
%      P  - Matrix of input vectors.
%    and returns a linear layer with the maximum stable
%    learning rate for learning with inputs P.
%
%  Examples
%
%    This code creates a single input, single neuron linear layer,
%    with input delays of 0 and 1, and a learning.  It is simulated
%    for the input sequence P1.
%
%      P1 = {0 -1 1 1 0 -1 1 0 0 1};
%      T1 = {0 -1 0 2 1 -1 0 1 0 1};
%
%      net = newlin(P1,T1,[0 1],0.01);
%      Y = net(P1)
%
%    Here the network adapts for inputs P1 and targets T1.
%
%      [net,Y,E,Pf] = adapt(net,P1,T1); Y
%
%    Here the linear layer continues to adapt for a new sequence
%    using the previous final conditions PF as initial conditions.
%
%      P2 = {1 0 -1 -1 1 1 1 0 -1};
%      T2 = {2 1 -1 -2 0 2 2 1 0};
%      [net,Y,E,Pf] = adapt(net,P2,T2,Pf); Y
%
%    Here we initialize the layer's weights and biases to new values.
%
%      net = init(net);
%
%    Here we train the newly initialized layer on the entire sequence
%    for 200 epochs to an error goal of 0.1.
%
%      P3 = [P1 P2];
%      T3 = [T1 T2];
%      net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.epochs">epochs</a> = 200;
%      net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>.<a href="matlab:doc nnparam.goal">goal</a> = 0.1;
%      net = train(net,P3,T3);
%      Y = net([P1 P2])
%
%  Algorithm
%
%    Linear layers consist of a single layer with the DOTPROD
%    weight function, NETSUM net input function, and PURELIN
%    transfer function.
%
%    The layer has a weight from the input and a bias.
%
%    Weights and biases are initialized with INITZERO.
%
%    Adaption and training are done with TRAINS and TRAINB,
%    which both update weight and bias values with LEARNWH.
%    Performance is measured with MSE.
%
%  See also NEWLIND, SIM, INIT, ADAPT, TRAIN, TRAINB, TRAINS.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.14 $ $Date: 2011/02/28 01:28:45 $

%% Boilerplate Code - Same for all Network Functions

persistent INFO;
if (nargin < 1), error(message('nnet:Args:NotEnough')); end
in1 = varargin{1};
if ischar(in1)
  switch in1
    case 'info',
      if isempty(INFO), INFO = get_info; end
      out1 = INFO;
  end
else
  out1 = create_network(varargin{:});
end

%% Boilerplate Code - Same for all Network Functions

%%
function info = get_info

info.function = mfilename;
info.name = 'Linear';
info.description = nnfcn.get_mhelp_title(mfilename);
info.type = 'nntype.network_fcn';
info.version = 6.0;

%%
function net = create_network(varargin)

if nargin < 2, error(message('nnet:Args:NotEnough')); end

v2 = varargin{2};

if (~iscell(v2)) && (numel(v2)==1)
  net = new_5p1_size(varargin{:});
else
  net = new_5p1_targets(varargin{:});
end

%=============================================================
function net = new_5p1_targets(p,t,id,lr)

if (nargin < 1), p = [-1 1]; end
if (nargin < 2), t = [-1 1]; end
if (nargin < 3), id = 0; end
if (nargin < 4), lr = 0.01; end

% Format
if isa(p,'cell'), p = cell2mat(p); end
if isa(t,'cell'), t = cell2mat(t); end

% Checking
if (~isa(p,'double')) || ~isreal(p)
  error(message('nnet:NNData:XNotMatorCell1Mat'))
end
if isa(t,'double') && all(size(t) == [1 1]), t = [-ones(t,1) ones(t,1)]; end
if (~isa(t,'double')) || ~isreal(t)
  error(message('nnet:NNData:XNotMatorCell1Mat'))
end
if (~isa(id,'double')) || ~isreal(id) || (size(id,1) ~= 1) || any(id ~= round(id)) || any(diff(id) <= 0)
  error(message('nnet:NNet:InputDelays'));
end
if (~isa(lr,'double')) || ~isreal(lr) || any(size(lr) ~= 1) || (lr < 0) || (lr > 1)
  error(message('nnet:newlin:LR'))
end

% Architecture
net = network(1,1,1,1,0,1,1);
net.inputs{1}.exampleInput = p;
net.outputs{1}.exampleOutput = t;
net.inputWeights{1,1}.delays = id;

% Performance
net.performFcn = 'mse';

% Learning (Adaption and Training)
net.inputWeights{1,1}.learnFcn = 'learnwh';
net.biases{1}.learnFcn = 'learnwh';
if (length(lr) > 1), lr = maxlinlr(lr,'bias'); end
net.inputWeights{1,1}.learnParam.lr = lr;
net.biases{1}.learnParam.lr = lr;

% Adaption
net.adaptFcn = 'adaptwb';

% Training
net.trainFcn = 'trainb';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'initzero';
net.biases{1}.initFcn = 'initzero';
net = init(net);

% Plots
net.plotFcns = {'plotperform','plottrainstate'};

%================================================================
function net = new_5p1_size(p,s,id,lr)
% Backward compatible to NNT 5.0

if nargin < 2, error(message('nnet:Args:NotEnough')), end

if (nargin >= 4) && (length(lr) > 1)
  if ((length(id) ~= 1) || (id ~= 0))
    error(message('nnet:newlin:ID'))
  end
end

% Defaults
if nargin < 3, id = 0; end
if nargin < 4, lr = 0.01; end

% Checking
if isa(p,'cell'), p = cell2mat(p); end
if (~isa(s,'double')) || ~isreal(s) || any(size(s) ~= 1) || (s<1) || (round(s) ~= s)
  error(message('nnet:NNet:NumNeuronNotPos'))
end
if (~isa(id,'double')) || ~isreal(id) || (size(id,1) ~= 1) || any(id ~= round(id)) || any(diff(id) <= 0)
  error(message('nnet:NNet:InputDelays'));
end
if (~isa(lr,'double')) || ~isreal(lr) || any(size(lr) ~= 1) || (lr < 0) || (lr > 1)
  error(message('nnet:newlin:LR'))
end
  
% Architecture
net = network(1,1,1,1,0,1,1);
net.inputs{1}.exampleInput = p;
net.layers{1}.size = s;
net.inputWeights{1,1}.delays = id;

% Performance
net.performFcn = 'mse';

% Learning (Adaption and Training)
net.inputWeights{1,1}.learnFcn = 'learnwh';
net.biases{1}.learnFcn = 'learnwh';
if (length(lr) > 1), lr = maxlinlr(lr,'bias'); end
net.inputWeights{1,1}.learnParam.lr = lr;
net.biases{1}.learnParam.lr = lr;

% Adaption
net.adaptFcn = 'adaptwb';

% Training
net.trainFcn = 'trainb';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'initzero';
net.biases{1}.initFcn = 'initzero';
net = init(net);

% Plots
net.plotFcns = {'plotperform','plottrainstate'};
