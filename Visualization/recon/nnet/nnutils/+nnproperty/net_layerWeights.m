% Neural network layerWeights property.
% 
% NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>
%
% This property holds structures of properties for each of the network's
% layer weights. It is always an Nl x Nl cell array, where Nl is the number
% of network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>).
%
% The structure defining the properties of the weight going to the ith
% layer from the jth layer (or a null matrix []) is located at
% net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j} if net.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>(i,j) is 1 (or 0).
%
% Each input weight has the following properties:
%
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initSettings">initSettings</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learn">learn</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnParam">learnParam</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_weightFcn">weightFcn</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_weightParam">weightParam</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_userdata">userdata</a>

% Copyright 2010 The MathWorks, Inc.
