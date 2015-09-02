function net = closeloop(net)
%CLOSELOOP Convert neural network open feedback to closed feedback loops.
%
%  <a href="matlab:doc closeloop">closeloop</a>(NET) takes a network and transforms any outputs marked
%  as open loop (i.e. NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> = 'open') to closed
%  loop.
%
%  This is done by replacing the input associated with the open loop
%  output (i.e. the input whose index is NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackInput">feedbackInput</a>)
%  with an interal layer weight connection.
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
% See also OPENLOOP, NOLOOP.

% Copyright 2010 The MathWorks, Inc.

for i=find(net.outputConnect)
  if strcmp(net.outputs{i}.feedbackMode,'open')
    net.outputs{i}.feedbackMode = 'closed';
  end
end


% TODO - Warning if zero-delay loop
