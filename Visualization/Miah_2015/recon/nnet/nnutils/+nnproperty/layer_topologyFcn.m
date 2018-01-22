% Neural network layer topologyFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a>
%
% This property defines the <a href="matlab:doc nntopology">topology function</a> used to calculate
% the ith layer's neuron positions (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>)
% from the layer's dimensions (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_dimensions">dimensions</a>).
%
% Side Effects:
%
%  Whenever this property is altered, the positions of the layer's neurons
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>) are updated.
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
