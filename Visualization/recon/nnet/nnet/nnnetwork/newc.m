function out1 = newc(varargin)
%NEWC Create a competitive layer.
%
%  Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%  The recommended function is <a href="matlab:doc competlayer">competlayer</a>.
%
%  Syntax
%
%   net = newc(P,S,KLR,CLR)
%
%  Description
%
%    Competitive layers are used to solve classification
%    problems.
%
%    NET = NEWC(P,S,KLR,CLR) takes these inputs,
%      P  - RxQ matrix of Q input vectors.
%      S  - Number of neurons.
%      KLR - Kohonen learning rate, default = 0.01.
%      CLR - Conscience learning rate, default = 0.001.
%    Returns a new competitive layer.
%
%  Examples
%
%    Here is a set of four two-element vectors P.
%
%      P = [.1 .8  .1 .9; .2 .9 .1 .8];
%
%    To competitive layer can be used to divide these inputs
%    into two classes.  First a two neuron layer is created
%    with two input elements ranging from 0 to 1, then it
%    is trained.
%
%      net = newc(P,2);
%      net = train(net,P);
%
%    The resulting network can then be simulated and its
%    output vectors converted to class indices.
%
%      Y = net(P)
%      Yc = vec2ind(Y)
%
%  Properties
%
%    Competitive layers consist of a single layer with the NEGDIST
%    weight function, NETSUM net input function, and the COMPET
%    transfer function.
%
%    The layer has a weight from the input, and a bias.
%
%    Weights and biases are initialized with MIDPOINT and INITCON.
%
%    Adaption and training are done with TRAINS and TRAINR,
%    which both update weight and bias values with the LEARNK
%    and LEARNCON learning functions.
%
%  See also SIM, INIT, ADAPT, TRAIN, TRAINS, TRAINR.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2011/02/28 01:28:40 $

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
info.name = 'Competitive';
info.description = nnfcn.get_mhelp_title(mfilename);
info.type = 'nntype.network_fcn';
info.version = 6.0;

%%
function net = create_network(p,s,klr,clr)

if nargin < 2, error(message('nnet:Args:NotEnough')); end

% Defaults
if nargin < 2, s = 20; end
if nargin < 3, klr = 0.01; end
if nargin < 4, clr = 0.001; end

% Format
if isa(p,'cell') && (size(p,1)==1), p = cell2mat(p); end

% Error Checking
if (~isa(p,'double')) || ~isreal(p)
  error(message('nnet:NNData:XNotMatorCell1Mat'))
end
if (~isa(s,'double')) || ~isreal(s) || any(size(s) ~= 1) || (s<1) || (round(s) ~= s)
  error(message('nnet:NNet:NumNeuronNotPos'))
end
if (~isa(klr,'double')) || any(size(klr) ~= 1) || (klr < 0) || (klr > 1)
  error(message('nnet:newc:KohonenLR'));
end
if (~isa(clr,'double')) || any(size(clr) ~= 1) || (clr < 0) || (clr > 1)
  error(message('nnet:newc:ConscienceLRNotReal'));
end
if (clr > klr)
  error(message('nnet:newc:ConscienceLRGTKohonenLR'));
end

% Architecture
net = network(1,1,1,1,0,1);

% Simulation
net.inputs{1}.exampleInput = p;
net.layers{1}.size = s;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';

% Learning
net.inputWeights{1,1}.learnFcn = 'learnk';
net.inputWeights{1,1}.learnParam.lr = klr;
net.biases{1}.learnFcn = 'learncon';
net.biases{1}.learnParam.lr = clr;

% Adaption
net.adaptFcn = 'adaptwb';

% Training
net.trainFcn = 'trainru';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.biases{1}.initFcn = 'initcon';
net.inputWeights{1,1}.initFcn = 'midpoint';

net = init(net);

