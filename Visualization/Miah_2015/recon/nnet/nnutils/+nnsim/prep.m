function [X,Xi,Ai,T,Q,TS,err] = prep(net,X,Xi,Ai,T)

% Copyright 2010-2012 The MathWorks, Inc.

% Q
if ~isempty(X) && (size(X{1},2) > 0)
  Q = size(X{1},2);
elseif ~isempty(Xi) && ~isempty(Xi{1})
  Q = size(Xi{1},2);
elseif ~isempty(Ai) && ~isempty(Ai{1})
  Q = size(Ai{1},2);
elseif ~isempty(T) && ~isempty(T{1})
  Q = size(T{1},2);
else
  Q = 0;
end

% TS
if (net.numInputs == 0) && (size(X,1) == 1) && (size(X{1},1)==0)
  TS = size(X,2);
  if (TS==1) && (size(T,2) > 0)
    TS = size(T,2);
  end
  X = cell(0,TS);
elseif size(X,2) > 0
  TS = size(X,2);
elseif size(T,2) > 0
  TS = size(T,2);
else
  TS = 0;
end

% Input
if isempty(X) || (net.numInputs == 0)
  X = cell(net.numInputs,TS);
  for i=1:net.numInputs
    for ts=1:TS
      X{i,ts} = zeros(net.inputs{i}.size,Q);
    end
  end
end
err = nntype.data('check',X);
if ~isempty(err), err = ['Inputs: ' err]; return; end
[Xn,Xq,Xts,Xs] = nnfast.nnsize(X);
if isempty(X), Xq = Q; end
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

% Input States
if isempty(Xi)
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
if isempty(Ai)
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
  err = 'Number of layers states does not match net.numLayers.'; return;
end
if (Aits ~= net.numLayerDelays)
  err = 'Number of layer state timesteps does not match net.numLayerDelays.'; return
end
% if (Ais > 0) && (Aits > 0)
%   for i=1:Ais
%     if Ain(i) ~= net.layers{i}.size
%       err = 'Layer state sizes does not match net.layers{:}.size.'; return;
%     end
%   end
% end

% Input/Target elements
for i=1:Xs
  if Xn(i) ~= net.inputs{i}.size
    istr = num2str(i);
    err = ['Input ' istr ' size does not match net.inputs{' istr '}.size.']; return;
  end
end
targetIndices = find(net.outputConnect);
for i=1:Ts
  ii = targetIndices(i);
  if Tn(i) ~= net.outputs{ii}.size
    istr = num2str(i);
    iistr = num2str(ii);
    err = ['Target ' istr ' size does not match net.outputs{' iistr '}.size.']; return;
  end
end
