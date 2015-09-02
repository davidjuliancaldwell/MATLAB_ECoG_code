function net = nn_feedback_open2closed(net,i)
%NN_FEEDBACK_OPEN2CLOSED Convert from open to closed feedback loop.

% Copyright 2010 The MathWorks, Inc.

% Input to remove
j = net.outputs{i}.feedbackInput;

% Move input weights to layer weights
net.layerConnect(:,i) = net.inputConnect(:,j);
net.layerWeights(:,i) = net.inputWeights(:,j);
net.LW(:,i) = net.IW(:,j);

% Insert the feedback delay
for k=find(net.layerConnect(:,i))'
  net.layerWeights{k,i}.delays = net.layerWeights{k,i}.delays + ...
    net.outputs{i}.feedbackDelay;
end

% Delete the input
net = nn_delete_input(net,j);
net.outputs{i}.feedbackInput = [];
net.outputs{i}.feedbackMode = 'closed';
