function d = nn_feedback_maxcloseddelay(net)
%NN_FEEDBACK_MAXDELAY Maximum closed feedback delay.

% Copyright 2010 The MathWorks, Inc.

d = 0;
for i=find(net.outputConnect)
  if strcmp(net.outputs{i}.feedbackMode,'closed')
    d = max([d net.outputs{i}.feedbackDelay]);
  end
end
