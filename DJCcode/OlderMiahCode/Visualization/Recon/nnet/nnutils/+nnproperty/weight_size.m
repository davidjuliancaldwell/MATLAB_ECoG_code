% Neural network weight size property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a> or NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a>
%
% This property defines the dimensions of the ith layer's weight matrix
% from the jth network input. It is always set to a two-element row vector
% indicating the number of rows and columns of the associated weight matrix
% (net.<a href="matlab:doc nnproperty.net_IW">IW</a>{i,j} or net.<a href="matlab:doc nnproperty.net_LW">LW</a>{i,j}). The first element is equal to the size of
% the ith layer (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>). The second element is equal to the
% product of the length of the weight's delay vectors and the size of
% the jth input or layer:
%
%   length(net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>) * net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{j}.<a href="matlab:doc nnproperty.input_size">size</a>
%   length(net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>) * net.<a href="matlab:doc nnproperty.net_layers">layers</a>{j}.<a href="matlab:doc nnproperty.layer_size">size</a>

% Copyright 2010 The MathWorks, Inc.
