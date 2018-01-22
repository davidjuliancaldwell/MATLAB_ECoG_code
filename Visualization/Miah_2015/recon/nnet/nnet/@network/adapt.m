function [net,Y,E,Xf,Af,tr]=adapt(net,X,T,Xi,Ai)
%ADAPT Adapt a neural network.
%
%  [NET,Y,E,Pf,Af,AR] = <a href="matlab:doc adapt">adapt</a>(NET,X,T,Xi,Ai) takes time series inputs X,
%  targets T, and initial input and layer delay states Xi and Ai.  The
%  network is adapted in response to the time series data, then the updated
%  network is returned with outputs Y, errors E, final input and layer
%  delay states Xf and Af, and the adaption record AR.
%
%  T only needs to be used for networks that require targets.  Xi and Ai
%  only to be used for networks that have input or layer delays.
%
%  The arguments have the following formats:
%    X  - NixTS cell array, each element P{i,ts} is an RixQ matrix.
%    T  - NtxTS cell array, each element T{i,ts} is an VixQ matrix.
%    Xi - NixID cell array, each element Pi{i,k} is an RixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Y  - NoxTS cell array, each element Y{i,ts} is an UixQ matrix.
%    E  - NoxTS cell array, each element E{i,ts} is an UixQ matrix.
%    Pf - NixID cell array, each element Pf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%  Where:
%    TS = Number of time steps
%    Q  = Number of time series (usually 1)
%    Ni = NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = NET.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>
%    No = NET.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>
%    ID = NET.<a href="matlab:doc nnproperty.net_numInputDelays">numInputDelays</a>
%    LD = NET.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Ui = NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%      
%  The columns of Xi, Xf, Ai, and Af are ordered from oldest delay
%  condition to most recent:
%    Xi{i,k} = input i at time ts=k-ID.
%    Xf{i,k} = input i at time ts=TS+k-ID.
%    Ai{i,k} = layer output i at time ts=k-LD.
%    Af{i,k} = layer output i at time ts=TS+k-LD.
%
%  Adaption is done in accordance with the network's NET.<a href="matlab:doc nnproperty.net_adaptFcn">adaptFcn</a> and
%  NET.<a href="matlab:doc nnproperty.net_adaptParam">adaptParam</a> properties. Adapt functions can also be called directly.
%
%  Here two sequences of 12 steps (where T1 is known to depend
%  on P1) are used to adapt a linear network.
%
%    x1 = {-1  0 1 0 1 1 -1  0 -1 1 0 1};
%    t1 = {-1 -1 1 1 1 2  0 -1 -1 0 1 1};
%    net = <a href="matlab:doc linearlayer">linearlayer</a>([0 1],0.5);
%    [net,y,e,xf] = <a href="matlab:doc adapt">adapt</a>(net,x1,t1);
%    perf1 = <a href="matlab:doc mse">mse</a>(e)
%      
%  The network can continue to be adapted to more of the time series, using
%  the previous Pf as the new initial delay conditions. The network's
%  mean squared error continues to drop.
%
%    x2 = {1 -1 -1 1 1 -1  0 0 0 1 -1 -1};
%    t2 = {2  0 -2 0 2  0 -1 0 0 1  0 -1};
%    [net,y,e,xf] = <a href="matlab:doc adapt">adapt</a>(net,x2,t2,xf);
%    perf2 = <a href="matlab:doc mse">mse</a>(e)
%
%  See also INIT, REVERT, SIM, TRAIN, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
%  $Revision: 1.13.4.14 $ $Date: 2012/04/20 19:11:48 $

% CHECK AND FORMAT ARGUMENTS
% --------------------------

if nargin < 1,error(message('nnet:Args:NotEnough')); end
if ~isa(net,'network'), error(message('nnet:adapt:NotANet')); end
if isempty(net.adaptFcn), error(message('nnet:adapt:Undef')); end

xMatrix = ~iscell(X);
if nargin < 3, T = {}; tMatrix = xMatrix; else tMatrix = ~iscell(T); end
if nargin < 4, Xi = {}; xiMatrix = xMatrix; else xiMatrix = ~iscell(Xi); end
if nargin < 5, Ai = {}; aiMatrix = xMatrix; else aiMatrix = ~iscell(Ai); end
[X,err] = nntype.data('format',X);
if ~isempty(err),nnerr.throw(nnerr.value(err,'Inputs'));end
if ~isempty(T), [T,err] = nntype.data('format',T); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Targets'));end
if ~isempty(Xi), [Xi,err] = nntype.data('format',Xi); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Input delay states'));end
if ~isempty(Ai), [Ai,err] = nntype.data('format',Ai); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Layer delay states'));end

% Network
net = struct(net);
[~,zeroDelayLoop] = nn.layer_order(net);
 if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end
[net,X,Xi,Ai,T,~,Q,TS,err] = nntraining.config(net,X,Xi,Ai,T,{1});
if ~isempty(err), nnerr.throw(err), end

% ADAPT NETWORK
% -------------

tools = nn7;
hints = tools.netHints(net,tools.hints);
hints.outputInd = find(net.outputConnect);

% Processed inputs
Pc = tools.pc(net,X,Xi,Q,TS,hints);

% Delayed Inputs
Pd = tools.pd(net,Pc,Q,TS,hints);

% Adapt network
[net,Ac,tr] = feval(net.adaptFcn,net,Pd,T,Ai);
net = class(net,'network');

% Network outputs, errors, final inputs
Al = Ac(:,net.numLayerDelays+(1:TS));
Y = nnMATLAB.post_outputs(hints,Al(hints.outputInd,:));
E = gsubtract(T,Y);
Xf = Pc(:,TS+(1:net.numInputDelays));
Af = Ac(:,TS+(1:net.numLayerDelays));

% FORMAT OUTPUT ARGUMENTS
% -----------------------

if (xMatrix), Y = cell2mat(Y); end
if (tMatrix), E = cell2mat(E); end
if (xiMatrix), Xf = cell2mat(Xf); end
if (aiMatrix), Af = cell2mat(Af); end
  
