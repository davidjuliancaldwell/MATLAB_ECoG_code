function setsiminit(sysName,netName,net,xi,ai,q)
%SETSIMINIT Set neural network Simulink block initial conditions
%
%  <a href="matlab:doc setsiminit">setsiminit</a>(sysName,netName,NET,Xi,Ai,Q) takes the system and network
%  names of a Simulink neural network generated with <a href="matlab:doc gensim">gensim</a>, initial
%  input and layer delays Xi and Ai, and optionally a sample number Q
%  (default is 1) and sets the Simulink network's initial delay states
%  to match the Qth set of values in Xi and Ai.
%  
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [x,t] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    <a href="matlab:doc view">view</a>(net)
%    [xs,xi,ai,ts] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%    net = <a href="matlab:doc train">train</a>(net,xs,ts,xi,ai);
%    y = net(xs,xi,ai);
%
%  Now the network is converted to closed loop, and the data is reformatted
%  to simulate the network's closed loop response.
%
%    net = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%    [xs,xi,ai] = <a href="matlab:doc preparets">preparets</a>(net,x,{},t);
%    y = net(xs,xi,ai);
%
%  Here the network is converted to a Simulink system with workspace
%  input and output ports. Its delay states are initialized, inputs X1
%  defined in the workspace, and it is ready to be simulated in Simulink.
%
%    [sysName,netName] = <a href="matlab:doc gensim">gensim</a>(net,'InputMode','Workspace',...
%      'OutputMode','WorkSpace','SolverMode','Discrete');
%    <a href="matlab:doc setsiminit">setsiminit</a>(sysName,netName,net,xi,ai,1);
%    x1 = <a href="matlab:doc nndata2sim">nndata2sim</a>(x,1,1);
%
% See also GENSIM, GETSIMINIT, NNDATA2SIM, SIM2NNDATA.

% Copyright 2010-2012 The MathWorks, Inc.

if (nargin < 3), error(message('nnet:Args:NotEnough')); end
if (nargin < 4), xi = cell(net.numInputs,0); end
if (nargin < 5), ai = cell(net.numOutputs,0); end
if (nargin < 6), q = 1; end
xi = nntype.data('format',xi,'Input delay states Xi');
ai = nntype.data('format',ai,'Layer delay states Ai');
[Nx,Qx,TSx,Mx] = nnsize(xi);
[Na,Qa,TSa,Ma] = nnsize(ai);
if Mx ~= net.numInputs
  mstr = num2str(Mx); zstr = num2str(net.numInputs);
  nnerr.throw(['Number of signals in input states Xi = ' mstr ...
    ', does not equal number of network inputs = ' zstr '.']);
end
if TSx < net.numInputDelays
  astr = num2str(TSx); bstr = num2str(net.numInputDelays);
  nnerr.throw(['Number of timesteps in input states Xi = ' astr ...
    ', is less than net.numInputDelays = ' bstr '.']);
end
if (net.numInputDelays > 0)
  for i=1:net.numInputs
    if (Nx(i) ~= net.inputs{i}.size)
      istr = num2str(i);  nstr = num2str(Nx(i));
      zstr = num2str(net.inputs{i}.size);
      nnerr.throw(['Number of elements in input states Xi{' istr '} = ' nstr  ...
        ', does not equal NET.inputs{' istr '}.size = ' zstr '.']);
    end
  end
  if ~isempty(xi)
    if (Qx == 0)
      error(message('nnet:NNData:XiNoSamples'));
    end
    if (Qx < q)
      nnerr.throw(['Input states Xi do not have Q = ' num2str(q) ' samples.'])
    end
  end  
end
if Ma ~= net.numLayers
  nnerr.throw(['Number of signals in layer states Ai = ' num2str(Mx) ...
    ', does not equal number of network layers = ' num2str(net.numLayers) '.']);
end
if TSa < net.numLayerDelays
  astr = num2str(TSa); bstr = num2str(net.numLayerDelays);
  nnerr.throw(['Number of timesteps in layer states Ai = ' astr ...
    ', is less than net.numInputDelays = ' bstr '.']);
end
if (net.numLayerDelays > 0)
  for i=1:net.numLayers
    if (Na(i) ~= net.layers{i}.size)
      istr = num2str(i);  nstr = num2str(Na(i));
      zstr = num2str(net.layers{i}.size);
      nnerr.throw(['Number of elements in layer states Ai{' istr '} = ' nstr  ...
        ', does not equal NET.layers{' istr '}.size = ' zstr '.']);
    end
  end
  if ~isempty(ai)
    if (Qa == 0)
      error(message('nnet:NNData:AiNoSamples'));
    end
     if (Qa < q)
      nnerr.throw(['Layers states Ai do not have Q = ' num2str(q) ' samples.'])
    end
  end
end

% Sample
xi = nnfast.getsamples(xi,q);
ai = nnfast.getsamples(ai,q);

% Process Input States
pi = nn7.pre_inputs(nn7.netHints(net),xi);

% Set input delay states
stateNames = get_param([sysName '/' netName],'maskVariables');
inputDelays = nn.input_delays(net);
for i=1:net.numInputs
  for k=1:inputDelays(i)
    ind = net.numInputDelays - k + 1;
    stateName = ['pi_input_' num2str(i) '_delayed_' num2str(k)];
    if ~strfind(stateName,stateNames)
      nnerr.throw('Simulink',['Block does not have mask variable "' stateName '".']);
    end
    set_param([sysName '/' netName],stateName,mat2str(pi{i,ind},100));
  end
end

% Set layer delay states
layerDelays = nn.layer_delays(net);
for i=1:net.numLayers
  for k=1:layerDelays(i)
    ind = net.numLayerDelays - k + 1;
    stateName = ['ai_layer_' num2str(i) '_delayed_' num2str(k)];
    if ~strfind(stateName,stateNames)
      nnerr.throw('Simulink',['Block does not have mask variable "' stateName '".']);
    end
    set_param([sysName '/' netName],stateName,mat2str(ai{i,ind},100));
  end
end
