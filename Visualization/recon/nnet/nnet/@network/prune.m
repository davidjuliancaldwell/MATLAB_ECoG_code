function [net,delInputs,delLayers,delOutputs,change] = prune(net)
%PRUNE Delete neural inputs, layers and outputs with sizes of zero.
%
% This network is useful for ensuring that a neural network has no zero
% sized inputs, layers or outputs, in preparation for generating a
% Simulink diagram of the network.  Simulink diagrams cannot contain
% signals with zero dimensions.
%
% [NET,DI,DL,DO] = <a href="matlab:doc prune">prune</a>(NET) takes a neural network and returns the
% network with zero sized inputs, layers and outputs deleted. It also
% returns the indices of the removed inputs DI, layers DL, and outputs DO.
%
% An input or output is deleted if either its size or processed size are 0.
% Layers are removed if there size is zero.
%
% Any input or layer weights with an empty delay vector are also deleted.
%
% Any layer whose output is not used is deleted.
%
% Here a NARX dynamic network is create which has one external input and a
% second input which feeds back from the output.
%
%   net = <a href="matlab:doc narxnet">narxnet</a>(10);
%   <a href="matlab:doc view">view</a>(net)
% 
% The network is then trained on a single random time-series problem with
% 50 timesteps.  The external input happens to have no elements.
%
%   X = <a href="matlab:doc nndata">nndata</a>(0,1,50);
%   T = <a href="matlab:doc nndata">nndata</a>(1,1,50);
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts);
%
% The network and data are then pruned before generating a Simulink
% diagram and initializing its input and layer states.
%
%   [net2,pi,pl,po] = <a href="matlab:doc prune">prune</a>(net);
%   [Xs2,Xi2,Ai2,Ts2] = <a href="matlab:doc prunedata">prunedata</a>(net,pi,pl,po,Xs,Xi,Ai,Ts)
%   [sysName,netName] = <a href="matlab:doc gensim">gensim</a>(net2);
%   <a href="matlab:doc
%   setsiminit">setsiminit</a>(sysName,netName,net2,Xi2,Ai2)
%
% See also GENSIM, SETSIMINIT.

% Copyright 2010-2012 The MathWorks, Inc.

change = false;

% Remove Zero-Sized Input weights
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      if isempty(net.inputWeights{i,j}.delays)
        net.inputConnect(i,j) = false;
        net.inputWeights{i,j} = [];
        net.IW{i,j} = [];
        change = true;
      end
    end
  end
end

% Remove Zero-Sized Layer weights
for i=1:net.numLayers
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      if isempty(net.layerWeights{i,j}.delays)
        net.layerConnect(i,j) = false;
        net.layerWeights{i,j} = [];
        net.LW{i,j} = [];
        change = true;
      end
    end
  end
end

% Remove Zero-Sized Outputs
delOutputs = false(1,net.numOutputs);
output2layer = find(net.outputConnect);
for i = net.numOutputs:-1:1
  ii = output2layer(i);
  if (net.outputs{ii}.size == 0) || (net.outputs{ii}.processedSize == 0)
    net = nn_delete_output(net,ii);
    delOutputs(i) = true;
    change = true;
  end
end
delOutputs = find(delOutputs);

% Remove Zero-Sized Layers
delLayers = false(1,net.numLayers);
for i=net.numLayers:-1:1
  if (net.layers{i}.size == 0)
    net = nn_delete_layer(net,i);
    delLayers(i) = true;
    change = true;
  end
end

% Remove unused layers
keptLayers = find(~delLayers);
done = false;
while (~done)
  done = true;
  for i= net.numLayers:-1:1
    if ~net.outputConnect(i) && all(net.layerConnect(:,i)==0)
      net = nn_delete_layer(net,i);
      delLayers(keptLayers(i)) = true;
      keptLayers(i) = [];
      done = false;
      change = true;
    end
  end
end
delLayers = find(delLayers);

% Remove Zero-Sized Inputs
delInputs = false(1,net.numInputs);
for i=net.numInputs:-1:1
  if (net.inputs{i}.size == 0) || (net.inputs{i}.processedSize == 0)
    net = nn_delete_input(net,i);
    delInputs(i) = true;
    change = true;
  end
end

% Remove unused inputs
keptInputs = find(~delInputs);
for i = net.numInputs:-1:1
  if ~any(net.inputConnect(:,i))
    net = nn_delete_input(net,i);
    delInputs(keptInputs(i)) = true;
    keptInputs(i) = [];
    change = true;
  end
end
delInputs = find(delInputs);

% Update dependent properties
if change
  net = nn_update_read_only(net);
end

    
