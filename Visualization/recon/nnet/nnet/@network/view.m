function out1 = view(net)
%VIEW View a neural network diagram.
%
%  <a href="matlab:doc view">view</a>(NET) generates a graphical view of a neural network.
%
%  Here a feedforward network is created, trained and viewed.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    <a href="matlab:doc view">view</a>(net)
%
%  See also GENSIM.

% Copyright 2007-2011 The MathWorks, Inc.

if nargin < 1,error(message('nnet:Args:NotEnough')); end
diagram = nn.view(net);
if nargout > 0, out1 = diagram; end
