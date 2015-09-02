function net = nn_feedback_open2none(net,i)
%NN_FEEDBACK_OPEN2NONE Convert from open to no feedback loop.

% Copyright 2010 The MathWorks, Inc.

% Input to remove
j = net.outputs{i}.feedbackInput;

% Delete the input
net = nn_delete_input(net,j);
net.outputs{i}.feedbackInput = [];
net.outputs{i}.feedbackMode = 'none';

