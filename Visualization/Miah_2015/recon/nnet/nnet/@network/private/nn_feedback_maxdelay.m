function d = nn_feedback_maxdelay(net)
%NN_FEEDBACK_MAXDELAY Maximum feedback delay.

% Copyright 2010 The MathWorks, Inc.

d = 0;
for i=find(net.outputConnect)
  d = max([d net.outputs{i}.feedbackDelay]);
end
