function net = nn_reorder_inputs(net,i)
%NN_REORDER_INPUTS Reorder network inputs.

% Copyright 2010 The MathWorks, Inc.

if (length(i) ~= net.numInputs) || all(sort(i) ~= 1:net.numInputs)
  error(message('nnet:NNet:BadInputOrder'));
end

% Redirect output-to-input open-loop connections
for j=find(net.outputConnect)
  fbi = net.outputs{j}.feedbackInput;
  if ~isempty(fbi)
    net.outputs{j}.feedbackInput = i(fbi);
  end
end

% Reorder inputs
net.inputConnect = net.inputConnect(:,i);
net.inputWeights = net.inputWeights(:,i);

