% Neural network weight delays property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a> or NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>
%
% Rhis property defines a tapped delay line between the jth input or layer
% and its weight to the ith layer. It must be set to a row vector of
% increasing values. The elements must be either 0 or positive integers.
%
% Side Effects
%
% Whenever this property is altered, the weight's size
% (net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a> or net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a>) and the
% dimensions of its weight matrix (net.<a href="matlab:doc nnproperty.net_IW">IW</a>{i,j} or net.<a href="matlab:doc nnproperty.net_LW">LW</a>{i,j}) are updated.

% Copyright 2010 The MathWorks, Inc.
