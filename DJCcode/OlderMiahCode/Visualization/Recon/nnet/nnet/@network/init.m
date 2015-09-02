function net=init(net)
%INIT Initialize a neural network.
%
%  <a href="matlab:doc init">init</a>(NET) takes a neural network NET and returns it with weight
%  and bias values updated according to the network initialization
%  function, indicated by NET.<a href="matlab:doc nnproperty.net_initFcn">initFcn</a>.
%
%  Here a feedforwark network is created, trained then initialized to new
%  initial weights and biases, then retrained for a different solution.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    net2 = <a href="matlab:doc init">init</a>(net);
%    net2 = <a href="matlab:doc train">train</a>(net2,x,t);
%
%  See also REVERT, SIM, ADAPT, TRAIN, INITLAY, INITNW, INITWB, RANDS.

%  Mark Beale, 11-31-97
%  Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.9.4.7 $ $Date: 2011/05/09 01:00:35 $

net = struct(net);

initFcn = net.initFcn;
if ~isempty(initFcn)
  net = feval(initFcn,net);
end

% Save values for future calls to REVERT
net.revert.IW = net.IW;
net.revert.LW = net.LW;
net.revert.b = net.b;

net = network(net);
