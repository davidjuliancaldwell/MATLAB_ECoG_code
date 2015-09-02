function net = nn_feedback_none2closed(net,i)
%NN_FEEDBACK_NONE2CLOSED Convert no feedback to closed feedback loop.

% Copyright 2010 The MathWorks, Inc.

net.outputs{i}.feedbackInput = [];
net.outputs{i}.feedbackMode = 'closed';
