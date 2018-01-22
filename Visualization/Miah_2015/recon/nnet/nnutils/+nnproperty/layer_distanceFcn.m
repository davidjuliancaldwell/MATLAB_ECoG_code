% Neural network layer distanceFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distanceFcn">distanceFcn</a>
%
% This property defines the <a href="matlab:doc nndistance">distance function</a> used to calculate
% the distances net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a> between neurons in the ith layer
% from the neuron positions net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>. Neuron distances
% are used by self-organizing maps.
%
% Side Effects:
%
% Whenever this property is altered, the distances between the layer's
% neurons (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a>) are updated and the distance
% parameters net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distanceParam">distanceParam</a>, are set to default values.

% Copyright 2010 The MathWorks, Inc.
