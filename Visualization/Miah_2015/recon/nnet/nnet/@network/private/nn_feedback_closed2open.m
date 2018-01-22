function net = nn_feedback_closed2open(net,i,j)
%NN_FEEDBACK_CLOSED2OPEN Convert from closed to open feedback loop.

% Copyright 2010 The MathWorks, Inc.

if nargin < 3, j = net.numInputs+1; end

% New input
net = nn_new_input(net,j);
net.inputs{j}.name = net.outputs{i}.name;
net.inputs{j}.feedbackOutput = i;
net.inputs{j}.size = net.outputs{i}.size;
net.inputs{j}.range = net.outputs{i}.range;
net.inputs{j}.processFcns = net.outputs{i}.processFcns;
net.inputs{j}.processParams = net.outputs{i}.processParams;  
net.inputs{j}.processSettings = net.outputs{i}.processSettings;  
net.inputs{j}.processedSize = net.outputs{i}.processedSize;
net.inputs{j}.processedRange = net.outputs{i}.processedRange;

% Connect output to input
net.outputs{i}.feedbackInput = j;
net.outputs{i}.feedbackMode = 'open';

% Move layer weights to input weights
net.inputConnect(:,j) = net.layerConnect(:,i);
net.inputWeights(:,j) = net.layerWeights(:,i);
net.IW(:,j) = net.LW(:,i);

% Remove the feedback delay
for k=find(net.inputConnect(:,j))'
  net.inputWeights{k,j}.delays = net.inputWeights{k,j}.delays - ...
    net.outputs{i}.feedbackDelay;
end

% Delete the old weights
net.layerConnect(:,i) = false(net.numLayers,1);
net.layerWeights(:,i) = cell(net.numLayers,1);
