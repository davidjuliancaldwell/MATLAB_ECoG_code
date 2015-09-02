function out1 = newsom(varargin)
%NEWSOM Create a self-organizing map.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = newsom(P,[d1,d2,...],tfcn,dfcn,steps,in)
%
%  Description
%
%    Competitive layers are used to solve classification
%    problems.
%
%    NET = NEWSOM(P,[D1,D2,...],TFCN,DFCN,OLR,OSTEPS,TLR,TNS) takes,
%      P  - RxQ matrix of Q representative input vectors.
%      Di     - Size of ith layer dimension, defaults = [5 8].
%      TFCN   - Topology function, default = 'hextop'.
%      DFCN   - Distance function, default = 'linkdist'.
%      STEPS  - Steps for neighborhood to shrink to 1, default = 100.
%      IN     - Initial neighborhood size, default = 3.
%    and returns a new self-organizing map.
%
%    The topology function TFCN can be HEXTOP, GRIDTOP, or RANDTOP.
%    The distance function can be LINKDIST, DIST, or MANDIST.
%
%  Examples
%
%    load simpleclass_dataset
%    net = newsom(simpleclassInputs,[8 8]);
%    net = train(net,simpleclassInputs);
%    plotsompos(net,simpleclassInputs)
%
%  Properties
%
%    SOMs consist of a single layer with the NEGDIST weight function,
%    NETSUM net input function, and the COMPET transfer function.
%
%    The layer has a weight from the input, but no bias.
%    The weight is initialized with MIDPOINT.
%
%    Adaption and training are done with TRAINS and TRAINR,
%    which both update the weight with LEARNSOM.
%
%  See also SIM, INIT, ADAPT, TRAIN, TRAINS, TRAINR.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2011/02/28 01:30:28 $

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
info.name = 'Self-Organizing Map';
info.description = nnfcn.get_mhelp_title(mfilename);
info.type = 'nntype.network_fcn';
info.version = 6.0;

%%
function net = create_network(varargin)

if nargin < 1, error(message('nnet:Args:NotEnough')), end

numArgs = length(varargin);
v51 = (size(varargin{1},2)==2) || ...
    (numArgs >= 7) || ...
    ((numArgs >= 5) && (varargin{5} ~= floor(varargin{5})));
if v51
  net = new_5p1(varargin{:});
else
  net = new_6p0(varargin{:});
end

%%
function net = new_6p0 (p,dims,tfcn,dfcn,steps,in)

% Defaults
if nargin < 2, dims = [5 8]; end
if nargin < 3, tfcn = 'hextop'; end
if nargin < 4, dfcn = 'linkdist'; end
if nargin < 5, steps = 100; end
if nargin < 6, in = 3; end

% Format
if isa(p,'cell'), p = cell2mat(p); end

% Error Checking
if (~isa(p,'double')) || ~isreal(p)
  error(message('nnet:NNData:XNotMatorCell1Mat'))
end
if (~isa(dims,'double')) || (~isreal(dims)) || (size(dims,1) ~= 1) || any(dims <= 0) || any(round(dims) ~= dims)
  error(message('nnet:newsom:Dimensions'))
end
if (~isa(steps,'double')) || (~steps == floor(steps)) || (steps < 1)
  error(message('nnet:newsom:Steps'));
end
if (~isa(in,'double')) || (~steps == floor(in)) || (in < 1)
  error(message('nnet:newsom:InitNeighborhood'));
end

% Architecture
net = network(1,1,0,1,0,1);

% Simulation
net.inputs{1}.exampleInput = p;
net.layers{1}.dimensions = dims;
net.layers{1}.topologyFcn = tfcn;
net.layers{1}.distanceFcn = dfcn;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';

% Learning
net.inputWeights{1,1}.learnFcn = 'learnsomb';
net.inputWeights{1,1}.learnParam.init_neighborhood = in;
net.inputWeights{1,1}.learnParam.steps = steps;

% Adaption
net.adaptFcn = 'adaptwb';

% Training
net.trainFcn = 'trainbu';
net.trainParam.epochs = 200;

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'initsompc';
net = init(net);

% Plots
net.plotFcns = ...
  {'plotsomtop','plotsomnc','plotsomnd','plotsomplanes','plotsomhits','plotsompos'};

%%
function net = new_5p1(p,dims,tfcn,dfcn,olr,osteps,tlr,tnd)

% Defaults
if nargin < 2, dims = [5 8]; end
if nargin < 3, tfcn = 'hextop'; end
if nargin < 4, dfcn = 'linkdist'; end
if nargin < 5, olr = 0.9; end
if nargin < 6, osteps = 1000; end
if nargin < 7, tlr = 0.02; end
if nargin < 8, tnd = 1; end

% Format
if isa(p,'cell'), p = cell2mat(p); end

% Error Checking
if (~isa(p,'double')) || ~isreal(p)
  error(message('nnet:NNData:XNotMatorCell1Mat'))
end
if (~isa(dims,'double')) || (~isreal(dims)) || (size(dims,1) ~= 1) || any(dims <= 0) || any(round(dims) ~= dims)
  error(message('nnet:newsom:Dimensions'))
end
if (~isa(olr,'double')) || (~isreal(olr)) || any(size(olr) ~= 1) || (olr < 0) || (olr > 1)
  error(message('nnet:newsom:OrderingLR'));
end
if (~isa(osteps,'double')) || (~isreal(osteps)) || any(size(osteps) ~= 1) || (osteps < 0) || (round(osteps) == olr)
  error(message('nnet:newsom:OrderingSteps'));
end
if (~isa(tlr,'double')) || (~isreal(tlr)) || any(size(tlr) ~= 1) || (tlr < 0) || (tlr > 1)
  error(message('nnet:newsom:TuningLR'));
end
if (~isa(tnd,'double')) || (~isreal(tnd)) || any(size(tnd) ~= 1) || (tnd < 0)
  error(message('nnet:newsom:TuningDistance'));
end

% Architecture
net = network(1,1,0,1,0,1);

% Simulation
net.inputs{1}.exampleInput = p;
net.layers{1}.dimensions = dims;
net.layers{1}.topologyFcn = tfcn;
net.layers{1}.distanceFcn = dfcn;
net.inputWeights{1,1}.weightFcn = 'negdist';
net.layers{1}.transferFcn = 'compet';

% Learning
net.inputWeights{1,1}.learnFcn = 'learnsom';
net.inputWeights{1,1}.learnParam.order_lr = olr;
net.inputWeights{1,1}.learnParam.order_steps = osteps;
net.inputWeights{1,1}.learnParam.tune_lr = tlr;
net.inputWeights{1,1}.learnParam.tune_nd = tnd;

% Adaption
net.adaptFcn = 'adaptwb';

% Training
net.trainFcn = 'trainru';

% Initialization
net.initFcn = 'initlay';
net.layers{1}.initFcn = 'initwb';
net.inputWeights{1,1}.initFcn = 'midpoint';
net = init(net);

% Plots
net.plotFcns = ...
  {'plotsomtop','plotsomnc','plotsomnd','plotsomplanes','plotsomhits','plotsompos'};
