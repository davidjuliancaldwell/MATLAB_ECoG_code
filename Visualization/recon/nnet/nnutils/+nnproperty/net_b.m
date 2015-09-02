% Neural network b property.
% 
% NET.b
%
% This property defines the bias vectors for each layer with a bias. It is
% always an Nl x 1 cell array, where Nl is the number of network layers
% (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>).
%
% The bias vector for the ith layer (or a null matrix []) is located at
% net.<a href="matlab:doc nnproperty.net_b">b</a>{i} if net.<a href="matlab:doc nnproperty.net_biasConnect">biasConnect</a>(i) is 1 (or 0).
%
% The number of elements in the bias vector is always equal to the size of
% the layer it is associated with (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>).
%
% This dimension can also be obtained from the bias properties:
%
%     net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_size">size</a>

% Copyright 2010 The MathWorks, Inc.
