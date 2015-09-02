function disp_problem(net,x,xi,ai,t,ew,mask,seed)
%DISP Display network/data test problem

% Copyright 2010-2012 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai] = nntest.rand_problem(seed);
elseif nargin == 5
  seed = t;
end

[Ni,Q,TS] = nnfast.nnsize(x);
if (Q==0)
  Q = numsamples(ai);
end
if (Q==0) && (nargin > 5)
  Q = numsamples(t);
end
No = nn.output_sizes(net);

if (net.numInputDelays + net.numLayerDelays + net.numFeedbackDelays) == 0
  type = 'Static';
else
  type = 'Dynamic';
end

if exist('matlabpool','file')
  poolSize = matlabpool('size');
else
  poolSize = 0;
end

disp(['[net,x,xi,ai,t] = nntest.rand_problem(' num2str(seed) ')']);
disp(' ');
disp(['Network Mode = ' type]);
disp(' ')
disp(['Number of inputs: ' num2str(net.numInputs)]);
disp(['Number of layers: ' num2str(net.numLayers)]);
disp(['Number of outputs: ' num2str(net.numOutputs)]);
disp(['Number of weights: ' num2str(sum(sum([net.inputConnect net.layerConnect])))]);
disp(['Number of biases: ' num2str(sum(net.biasConnect))]);
disp(' ')
disp(['Number of input delays: ' num2str(sum(net.numInputDelays))]);
disp(['Number of layer delays: ' num2str(sum(net.numLayerDelays))]);
disp(' ')
disp(['Number of wb values: ' num2str(net.numWeightElements)]);
disp(' ')
disp(['Number of input elements: ' num2str(sum(Ni))]);
disp(['Number of output elements: ' num2str(sum(No))]);
disp(' ')
disp(['Number of samples: ' num2str(Q)]);
disp(['Number of timesteps: ' num2str(TS)]);
disp(' ')
disp(['Number of MATLAB workers: ' num2str(poolSize)]);
disp(' ')
