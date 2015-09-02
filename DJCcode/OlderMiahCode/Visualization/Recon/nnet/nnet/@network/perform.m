function perf = perform(net,t,y,ew)
%PERFORM Calculate network performance.
%
%  <a href="matlab:doc perform">perform</a>(NET,T,Y,EW) takes a network, targets T and
%  outputs Y, and optionally error weights EW, and returns performance using
%  the network's default performance function NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a>.
%
%  Here a simple fitting problem is solved with a feed-forward network
%  and its performance calculated.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    perf = <a href="matlab:doc perform">perform</a>(net,t,y)
%
%  See also TRAIN, ADAPT, SIM, VIEW.

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 3, error(message('nnet:Args:NotEnough')); end
[net,err] = nntype.network('format',net);
if ~isempty(err),nnerr.throw(nnerr.value(err,'NET')); end
if isempty(net.performFcn),
  error(message('nnet:NNet:PerformFcnUndefined'));
end
if nargin < 4, ew = {1}; end

if ~iscell(t), t = {t}; end
if ~iscell(y), y = {y}; end
if ~iscell(ew), ew = {ew}; end

perf = nncalc.perform(net,t,y,ew);
