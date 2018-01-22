% Neural network layer size property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%
% This property defines the number of neurons in the ith layer. It can
% be set to 0 or a positive integer.
%
% Side Effects:
%
% Whenever this property is altered, the sizes of any input weights going
% to the layer (net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,:}.<a href="matlab:doc nnproperty.weight_size">size</a>), any layer weights going to
% the layer (net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,:}.<a href="matlab:doc nnproperty.weight_size">size</a>) or coming from the layer
% (net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,:}.<a href="matlab:doc nnproperty.weight_size">size</a>), and the layer's bias (net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_size">size</a>),
% change.
%
% The dimensions of the corresponding weight matrices (net.<a href="matlab:doc nnproperty.net_IW">IW</a>{i,:},
% net.<a href="matlab:doc nnproperty.net_LW">LW</a>{i,:}, net.<a href="matlab:doc nnproperty.net_LW">LW</a>{:,i}), and biases (net.<a href="matlab:doc nnproperty.net_b">b</a>{i}) also change.
%
% Changing this property also changes the size of the layer's output
% (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>) if it exists.
%
% Finally, when this property is altered, the dimensions of the layer's
% neurons (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_dimensions">dimensions</a>) are set to the same value. (This
% results in a one-dimensional arrangement of neurons. If another
% arrangement is required, set the dimensions property directly
% instead of using size.)

% Copyright 2010 The MathWorks, Inc.
