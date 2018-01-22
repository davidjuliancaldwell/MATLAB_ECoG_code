function net = nn_feedback_none2open(net,i,j)
%NN_FEEDBACK_NONE2OPEN Convert no feedback to open feedback loop.

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

% Connect open feedback
net.outputs{i}.feedbackInput = j;
net.outputs{i}.feedbackMode = 'open';
