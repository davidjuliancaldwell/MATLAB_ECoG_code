function [xi,ai] = getsiminit(sysName,netName,net)
%GETSIMINIT Get neural network Simulink block initial conditions
%
% [Xi,Ai] = <a href="matlab:doc getsiminit">getsiminit</a>(sysName,netName,net) takes the system and network
% names of a Simulink neural network generated with <a href="matlab:doc gensim">gensim</a>, and
% returns initial input and layer delays Xi and Ai.
%  
% Here a NARX network is designed. The NARX network has a standard input
% and an open loop feedback output to an associated feedback input.
%
%   [x,t] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   <a href="matlab:doc view">view</a>(net)
%   [xs,xi,ai,ts] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%   net = <a href="matlab:doc train">train</a>(net,xs,ts,xi,ai);
%   y = net(xs,xi,ai);
%
% Now the network is converted to closed loop, and the data is reformatted
% to simulate the network's closed loop response.
%
%   net = <a href="matlab:doc closeloop">closeloop</a>(net);
%   <a href="matlab:doc view">view</a>(net)
%   [xs,xi,ai] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%   y = net(xs,xi,ai);
%
% Here the network is converted to a Simulink system with workspace
% input and output ports. Its delay states are initialized, inputs X1
% defined in the workspace, and it is ready to be simulated in Simulink.
%
%   [sysName,netName] = <a href="matlab:doc gensim">gensim</a>(net,'InputMode','Workspace',...
%     'OutputMode','WorkSpace','SolverMode','Discrete');
%   <a href="matlab:doc setsiminit">setsiminit</a>(sysName,netName,net,xi,ai,1);
%   x1 = <a href="matlab:doc nndata2sim">nndata2sim</a>(x,1,1);
%
% Here the initial conditions set above are obtained from the diagram.
%
%   [xi,ai] = <a href="matlab:doc getsiminit">getsiminit</a>(sysName,netName,net);
%
% See also GENSIM, GETSIMINIT, NNDATA2SIM, SIM2NNDATA.

% Copyright 2010-2012 The MathWorks, Inc.

if (nargin < 3), error(message('nnet:Args:NotEnough')); end

% Process Input States
% Get input delay states
inputSizes = zeros(net.numInputs,1);
for i=1:net.numInputs, inputSizes(i) = net.inputs{i}.processedSize; end
pi = nndata(inputSizes,1,net.numInputDelays,NaN);
stateNames = get_param([sysName '/' netName],'maskVariables');
inputDelays = nn.input_delays(net);
for i=1:net.numInputs
  for k=1:inputDelays(i)
    ind = net.numInputDelays - k + 1;
    stateName = ['pi_input_' num2str(i) '_delayed_' num2str(k)];
    if ~strfind(stateName,stateNames)
      nnerr.throw('Simulink',['Block does not have mask variable "' stateName '".']);
    end
    pi{i,ind} = eval(get_param([sysName '/' netName],stateName));
  end
end

% Reverse Process Inputs
xi = nn7.post_inputs(nn7.netHints(net),pi);

% Set layer delay states
layerSizes = zeros(net.numLayers,1);
for i=1:net.numLayers, layerSizes(i) = net.layers{i}.size; end
layerDelays = nn.layer_delays(net);
ai = nndata(layerSizes,1,net.numLayerDelays,NaN);
for i=1:net.numLayers
  for k=1:layerDelays(i)
    ind = net.numLayerDelays - k + 1;
    stateName = ['ai_layer_' num2str(i) '_delayed_' num2str(k)];
    if ~strfind(stateName,stateNames)
      nnerr.throw('Simulink',['Block does not have mask variable "' stateName '".']);
    end
    ai{i,ind} = eval(get_param([sysName '/' netName],stateName));
  end
end
