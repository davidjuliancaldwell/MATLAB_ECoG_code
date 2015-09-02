function [x,xi,ai,t] = prunedata(net,pi,pl,po,x,xi,ai,t)
%PRUNEDATA Prune data for a pruned network
%
% The function <a href="matlab:doc prune">prune</a> removes zero-sized and unused elements of a
% neural network.  This function, <a href="matlab:doc prunedata">prunedata</a> allows data formatted
% for the original network to be reformatted to work with the pruned
% network.
%
% One reason to prune a network and data of zero-sized and unused
% elements is for compatibility with Simulink before calling <a href="matlab:doc gensim">gensim</a>.
%
% [X,Xi,Ai,T] = <a href="matlab:doc prunedata">prunedata</a>(NET,PI,PL,PO,NET,X,Xi,Ai,T) takes a pruned
% neural network NET, the indices of pruned inputs PI, layers PL, and
% outputs PO, along with input data X, initial input states Xi, initial
% layer states Ai, and targets T.  It prunes the data accordingly.
%
% Each of the data arguments, X, Xi, Ai and T, are optional and may be
% left out or set to the empty cell {}.
%
% Here a NARX dynamic network is create which has one external input and a
% second input which feeds back from the output.
%
%   net = <a href="matlab:doc narxnet">narxnet</a>(10);
%   <a href="matlab:doc view">view</a>(net)
% 
% The network is then trained on a single random time-series problem with
% 50 timesteps.  The external input happens to have no elements.
%
%   X = <a href="matlab:doc nndata">nndata</a>(0,1,50);
%   T = <a href="matlab:doc nndata">nndata</a>(1,1,50);
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts);
%
% The network and data are then pruned before generating a Simulink
% diagram and initializing its input and layer states.
%
%   [net2,pi,pl,po] = <a href="matlab:doc prune">prune</a>(net);
%   [Xs2,Xi2,Ai2,Ts2] = <a href="matlab:doc prunedata">prunedata</a>(net,pi,pl,po,Xs,Xi,Ai,Ts)
%   [sysName,netName] = <a href="matlab:doc gensim">gensim</a>(net2);
%   <a href="matlab:doc setsiminit">setsiminit</a>(sysName,netName,net2,Xi2,Ai2)
%
% See also PRUNE, GENSIM, INITSIM.

% Copyright 2010 The MathWorks, Inc.

if nargin < 4, error(message('nnet:Args:NotEnough')); end
if nargin < 5, x = {}; end
if nargin < 6, xi = {}; end
if nargin < 7, ai = {}; end
if nargin < 8, t = {}; end

if ~all(size(x)==0)
  x(pi,:) = [];
end

if ~all(size(xi)==0)
  xi(pi,:) = [];
  xi = xi(:,size(xi,2)+1-(1:net.numInputDelays));
end

if ~all(size(ai)==0)
  ai(pl,:) = [];
  ai = ai(:,size(ai,2)+1-(1:net.numLayerDelays));
end

if ~all(size(t)==0)
  t(po,:) = [];
end
