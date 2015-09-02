function [net,X,Xi,Ai,T,EW,Q,TS,err] = config(net,X,Xi,Ai,T,EW,configNetEnable)

% Copyright 2010-2012 The MathWorks, Inc.

% Define default return values in case error is returned.
if nargin < 7, configNetEnable = true; end
Q = [];
TS = [];

% Input
% Missing inputs filled in with 0 column values
if all(size(X)==0)
  X = cell(net.numInputs,1);
  for i=1:net.numInputs
    X{i} = zeros(net.inputs{i}.size,0);
  end
end
err = nntype.data('check',X);
if ~isempty(err), err = ['Inputs: ' err]; return; end
[Xn,Xq,Xts,Xs] = nnfast.nnsize(X);
if (Xs == 1) && (net.numInputs ~= 1)
  Nn = zeros(1,net.numInputs);
  for i=1:net.numInputs,Nn(i) = net.inputs{i}.size; end
  if (Xn == sum(Nn))
    X2 = cell(net.numInputs,Xts);
    for ts=1:Xts
      X2(:,ts) = mat2cell(X{1,ts},Nn,Xq);
    end
    X = X2;
    Xn = Nn;
    Xs = net.numInputs;
  end
end
if (Xs ~= net.numInputs)
  err = 'Number of inputs does not match net.numInputs.'; return;
end  

% Target
% Missing targets filled in with NaN values
% TODO - Dimensionally expand targets
if isempty(T)
  targetIndices = find(net.outputConnect);
  T = cell(net.numOutputs,Xts);
  for i=1:net.numOutputs
    ii = targetIndices(i);
    ti = NaN(net.outputs{ii}.size,Xq);
    for j=1:Xts, T{i,j} = ti; end
  end
end
err = nntype.data('check',T);
if ~isempty(err), err = ['Targets: ' err]; return; end
[Tn,Tq,Tts,Ts] = nnfast.nnsize(T);
if ((Ts == 0) || (Tts ==0)) && (Tq == 0)
  Tq = Xq;
end
if (Xs == 0), Xq = Tq; end
if (Xs == 0) && (Xts == 0)
  Xts = Tts;
  X = cell(0,Xts);
end
if (Tq ~= Xq)
  err = 'Inputs and targets have different numbers of samples.'; return
end
if (Tts ~= Xts)
  err = 'Inputs and targets have different numbers of timesteps.'; return
end
if (Ts == 1) && (net.numOutputs ~= 1)
  Nn = zeros(1,net.numOutputs);
  outputInd = find(net.outputConnect);
  for i=1:net.numOutputs,Nn(i) = net.outputs{outputInd(i)}.size; end
  if (Tn == sum(Nn))
    T2 = cell(net.numOutputs,Xts);
    for ts=1:Xts
      T2(:,ts) = mat2cell(T{1,ts},Nn,Tq);
    end
    T = T2;
    Tn = Nn;
    Ts = net.numOutputs;
  end
end
if (Ts ~= net.numOutputs)
  err = 'Number of targets does not match net.numOutputs.'; return;
end

% Check Configuration
configureInputs = false;
for i=1:Xs
  if (net.inputs{i}.size == 0) && (Xn(i) ~= 0)
    configureInputs = configureInputs || (Xn(i) ~= 0);
  elseif Xn(i) ~= net.inputs{i}.size
     istr = num2str(i);
     err = ['Input data size does not match net.inputs{' istr '}.size.'];
     return;
  end
end
configureOutputs = false;
Tindices = find(net.outputConnect);
for i=1:Ts
  ii = Tindices(i);
  if (net.outputs{ii}.size == 0)
    configureOutputs = configureOutputs || (Tn(i) ~= 0);
  elseif Tn(i) ~= net.outputs{ii}.size
    iistr = num2str(ii);
    err = ['Output data size does not match net.outputs{' iistr '}.size.'];
    return;
  end
end

% Configure
if ~configNetEnable && (configureInputs || configureOutputs)
  err = 'Need to CONFIGURE network inputs and outputs before training.';
  return;
end
if configureInputs && configureOutputs;
  net = configure(network(net),X,T);
  net = struct(net);
elseif configureInputs
  net = configure(network(net),X);
  net = struct(net);
elseif configureOutputs
  net = configure(network(net),'targets',T);
  net = struct(net);
end

% Input States
% Missing input states filled in with zeros
if isempty(Xi) || (isscalar(Xi) && all(size(Xi{1}) == 0))
  Xi = cell(net.numInputs,net.numInputDelays);
  for i=1:net.numInputs
    xi = zeros(net.inputs{i}.size,Xq);
    for j=1:net.numInputDelays, Xi{i,j} = xi; end
  end
end
err = nntype.data('check',Xi);
if ~isempty(err), err = ['Input states: ' err]; return; end
[Xin,Xiq,Xits,Xis] = nnfast.nnsize(Xi);
if ((Xis == 0) || (Xits ==0)) && (Xiq == 0)
  Xiq = Xq;
end
if (Xiq ~= Xq)
  err = 'Inputs and input states have different numbers of samples.'; return
end
if (Xis ~= net.numInputs)
  err = 'Number of input states does not match net.numInputs.'; return;
end
if (Xits ~= net.numInputDelays)
  err = 'Number of input state timesteps does not match net.numInputDelays.'; return
end
if (Xis > 0) && (Xits > 0)
  for i=1:Xis
    if Xin(i) ~= net.inputs{i}.size
      err = 'Input state sizes does not match net.inputs{:}.size.'; return;
    end
  end
end

% Layer States
% Missing layer states filled in with zeros
if isempty(Ai) || (isscalar(Ai) && all(size(Ai{1}) == 0))
  Ai = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    ai = zeros(net.layers{i}.size,Xq);
    for j=1:net.numLayerDelays, Ai{i,j} = ai; end
  end
end
err = nntype.data('check',Ai);
if ~isempty(err), err = ['Layer states: ' err]; return; end
[Ain,Aiq,Aits,Ais] = nnfast.nnsize(Ai);
if ((Ais == 0) || (Aits ==0)) && (Aiq == 0)
  Aiq = Xq;
end
if (Aiq ~= Xq)
  err = 'Inputs and layer states have different numbers of samples.'; return
end
if (Ais ~= net.numLayers)
  err = 'Number of layer states does not match net.numLayers.'; return;
end
if (Aits ~= net.numLayerDelays)
  err = 'Number of layer state timesteps does not match net.numLayerDelays.'; return
end
if (Ais > 0) && (Aits > 0)
  for i=1:Ais
    if Ain(i) ~= net.layers{i}.size
      err = 'Layer state size does not match net.layers{:}.size.'; return;
    end
  end
end

% EW
if isempty(EW)
  EW = {1};
elseif ~iscell(EW)
  EW = {EW};
end

Q = Xq;
TS = Xts;

