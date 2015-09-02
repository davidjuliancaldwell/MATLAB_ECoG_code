% Neural network layer dimensions property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_dimensions">dimensions</a>
%
% This property defines the physical dimensions of the ith layer's neurons.
% Being able to arrange a layer's neurons in a multidimensional manner is
% important for self-organizing maps.
%
% It can be set to any row vector of 0 or positive integer elements, where
% the product of all the elements becomes the number of neurons in the
% layer (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>).
%
% Layer dimensions are used to calculate the neuron positions within the
% layer (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>) using the layer's topology function
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_topologyFcn">topologyFcn</a>).
%
% Side Effects:
%
% Whenever this property is altered, the layer's size (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>)
% changes to remain consistent. The layer's neuron positions
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_positions">positions</a>) and the distances between the neurons
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_distances">distances</a>) are also updated.

% Copyright 2010 The MathWorks, Inc.
