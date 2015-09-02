function out1 = newpr(varargin)
%NEWPR Create a pattern recognition network.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = newpr(P,T,S,TF,BTF,BLF,PF,IPF,OPF,DDF)
%
%  Description
%
%    NEWPR(P,T,S,TF,BTF,BLF,PF,IPF,OPF,DDF) takes,
%      P  - RxQ1 matrix of Q1 representative R-element input vectors.
%      T  - SNxQ2 matrix of Q2 representative SN-element target vectors.
%      Si  - Sizes of N-1 hidden layers, S1 to S(N-1), default = [].
%            (Output layer size SN is determined from T.)
%      TFi - Transfer function of ith layer. Default is 'tansig' for
%            hidden layers, and 'linear' for output layer.
%      BTF - Backprop network training function, default = 'trainlm'.
%      BLF - Backprop weight/bias learning function, default = 'learngdm'.
%      PF  - Performance function, default = 'mse'.
%      IPF - Row cell array of input processing functions.
%            Default is {'fixunknowns','remconstantrows','mapminmax'}.
%      OPF - Row cell array of output processing functions.
%            Default is {'remconstantrows','mapminmax'}.
%      DDF - Data division function, default = 'dividerand';
%    and returns an N layer feed-forward backprop network.
%
%    The transfer functions TF{i} can be any differentiable transfer
%    function such as TANSIG, LOGSIG, or PURELIN.
%
%    The training function BTF can be any of the backprop training
%    functions such as TRAINLM, TRAINBFG, TRAINRP, TRAINGD, etc.
%
%    *WARNING*: TRAINLM is the default training function because it
%    is very fast, but it requires a lot of memory to run.  If you get
%    an "out-of-memory" error when training try doing one of these:
%
%    (1) Slow TRAINLM training, but reduce memory requirements, by
%        setting NET.efficiency.memoryReduction to 2 or more. (See HELP TRAINLM.)
%    (2) Use TRAINBFG, which is slower but more memory efficient than TRAINLM.
%    (3) Use TRAINRP which is slower but more memory efficient than TRAINBFG.
%
%    The learning function BLF can be either of the backpropagation
%    learning functions such as LEARNGD, or LEARNGDM.
%
%    The performance function can be any of the differentiable performance
%    functions such as MSE or MSEREG.
%
%  Examples
%
%    load simpleclass_dataset
%    net = newpr(simpleclassInputs,simpleclassTargets,20);
%    net = train(net,simpleclassInputs,simpleclassTargets);
%    simpleclassOutputs = net(simpleclassInputs);
%
%  Algorithm
%
%    NEWPR returns a network exactly as NEWFF would, but with an
%    output layer transfer function of 'TANSIG' and additional plotting
%    functions included in the network's net.plotFcn property.
%
%  See also NEWFF, NEWCF, NEWELM, SIM, INIT, ADAPT, TRAIN, TRAINS

% Copyright 2007-2010 The MathWorks, Inc.

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
info.name = 'Pattern Recognition';
info.description = nnfcn.get_mhelp_title(mfilename);
info.type = 'nntype.network_fcn';
info.version = 6.0;

%%
function net = create_network(varargin)

if nargin < 2, error(message('nnet:Args:NotEnough')), end

net = newff(varargin{:});
net.layers{net.numLayers}.transferFcn = 'tansig';
net.trainFcn = 'trainscg';
net.plotFcns = {'plotperform','plottrainstate','plotconfusion','plotroc'};
%net.inputs{1}.processParams{3}.ymin = -0.99;
%net.inputs{1}.processParams{3}.ymax = 0.99;

