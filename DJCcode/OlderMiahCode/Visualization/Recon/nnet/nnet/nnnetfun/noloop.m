function net = noloop(net)
%NOLOOP Remove neural network open and closed feedback loops.
%
%  <a href="matlab:doc noloop">noloop</a>(NET) takes a network and transforms any outputs marked
%  as open or closed loop (i.e. NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> = 'open' or
%  'closed') to no loop (i.e. '').
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
%  Now the network is converted to no loop form.  The output and second
%  input are no longer associated.
%
%    net = <a href="matlab:doc noloop">noloop</a>(net);
%    <a href="matlab:doc view">view</a>(net)
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,T);
%    Y = net(Xs,Xi,Ai)
%
% See also OPENLOOP, CLOSEDLOOP.

% Copyright 2010 The MathWorks, Inc.

for i=find(net.outputConnect)
  if ~isempty(net.outputs{i}.feedbackMode)
    net.outputs{i}.feedbackMode = '';
  end
end
