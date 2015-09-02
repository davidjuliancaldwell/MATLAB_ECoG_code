function net = nn_delete_input(net,i)
%NN_DELETE_INPUT Delete input from network.

% Copyright 2010 The MathWorks, Inc.

if i > net.numInputs
  error(message('nnet:NNData:CannotInsertInput'));
end

% Decrement any output-to-input feedback connections
% that connect to input i or greater.
for j=find(net.outputConnect)
  if net.outputs{j}.feedbackInput >= i
    net.outputs{j}.feedbackInput = net.outputs{j}.feedbackInput - 1;
  end
end

% Delete input i
n = [(1:(i-1)) ((i+1):net.numInputs)];
net.numInputs = net.numInputs - 1;
net.inputs = net.inputs(n);
net.inputConnect = net.inputConnect(:,n);
net.inputWeights = net.inputWeights(:,n);
net.IW = net.IW(:,n);
