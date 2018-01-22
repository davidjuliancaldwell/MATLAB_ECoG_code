% Neural network LW property.
% 
% NET.<a href="matlab:doc nnproperty.net_LW">LW</a>
%
% This property defines the weight matrices of weights going to layers
% from other layers. It is always an Nl x Nl cell array, where Nl is the
% number of network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>).
%
% The weight matrix for the weight going to the ith layer from the jth
% layer (or a null matrix []) is located at net.<a href="matlab:doc nnproperty.net_LW">LW</a>{i,j} if
% net.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>(i,j) is 1 (or 0).
%
% The weight matrix has as many rows as the size of the layer it goes to
% (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>). It has as many columns as the product of the size
% of the layer it comes from with the number of delays associated with the
% weight:
%
%     net.<a href="matlab:doc nnproperty.net_layers">layers</a>{j}.<a href="matlab:doc nnproperty.layer_size">size</a> * length(net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>)
%
% These dimensions can also be obtained from the layer weight properties:
%
%     net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a>

% Copyright 2010 The MathWorks, Inc.
