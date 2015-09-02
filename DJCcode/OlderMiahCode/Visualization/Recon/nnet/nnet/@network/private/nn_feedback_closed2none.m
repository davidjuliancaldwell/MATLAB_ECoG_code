function net = nn_feedback_closed2none(net,i)
%NN_FEEDBACK_CLOSED2NONE Convert from closed to no feedback loop.

% Copyright 2010 The MathWorks, Inc.

% New input
net.outputs{i}.feedbackInput = [];
net.outputs{i}.feedbackMode = 'none';
