% Neural network layer distances property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a>
%
% This read-only property defines the distances between neurons in the ith
% layer. These distances are used by self-organizing maps.
%
% It is always set to the result of applying the layer's distance function
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distanceFcn">distanceFcn</a>) to the positions of the layer's neurons
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>).

% Copyright 2010 The MathWorks, Inc.
