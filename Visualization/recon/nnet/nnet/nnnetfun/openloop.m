function net = openloop(net)
%OPENLOOP Convert neural network closed feedback to open feedback loops.
%
%  <a href="matlab:doc openloop">openloop</a>(NET) takes a network and transforms any outputs marked
%  as closed loop (i.e. NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> = 'closed') to open
%  loop.
%
%  This is done by replacing the any layer connections coming from closed
%  loop outputs with input weights coming from a new input, and associating
%  the new input with the output (NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackInput">feedbackInput</a> is set to
%  the index of the new input.)
%
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%    net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(Xs,Xi,Ai)
%
%  Now the network is converted to closed loop form.  The closed loop
%  network can now be used for multi-timestep prediction.
%
%    net = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%    Y = net(Xs,Xi,Ai)
%
%  Now the network is reconverted to open loop form.  The closed loop
%
%    net = <a href="matlab:doc openloop">openloop</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%
% See also CLOSEDLOOP, NOLOOP.

% Copyright 2010 The MathWorks, Inc.

for i=find(net.outputConnect)
  if strcmp(net.outputs{i}.feedbackMode,'closed')
    net.outputs{i}.feedbackMode = 'open';
  end
end
