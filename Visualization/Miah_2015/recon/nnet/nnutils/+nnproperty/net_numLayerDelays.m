% Neural network numLayerDelays property.
% 
% NET.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%
% This property indicates the number of time steps of past layer outputs
% that must be supplied to simulate the network. It is always set to the
% maximum delay value associated with any of the network's layer weights
% (net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>).
%
% This value is used by <a href="matlab:doc preparets">preparets</a> to format time series data properly 
% for specific dynamic networks.
%
% See also PREPARETS

% Copyright 2010 The MathWorks, Inc.
