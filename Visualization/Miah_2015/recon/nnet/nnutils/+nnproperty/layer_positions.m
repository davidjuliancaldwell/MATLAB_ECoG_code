% Neural network layer positions property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>
%
% This read-only property defines the positions of neurons in the ith
% layer. These positions are used by self-organizing maps.
%
% It is always set to the result of applying the layer's topology function
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a>) to the positions of the layer's dimensions
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_dimensions">dimensions</a>).
%
% Use <a href="matlab:doc plotsomtop">plotsomtop</a> to plot the positions of a layer's neurons. For instance,
% if the first-layer neurons of a network are arranged with dimensions
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_dimensions">dimensions</a>) of [4 5], and the topology function
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{1}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a>) is hextop, the neurons? positions can be
% plotted as follows:
%
%   net = selforgmap([8 8])
%   plotsomtop(net)
%
% See also SELFORGMAP, PLOTSOMTOP

% Copyright 2010 The MathWorks, Inc.
