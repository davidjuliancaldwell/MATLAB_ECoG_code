% Neural network inputWeights property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>
%
% This property holds structures of properties for each of the network's
% input weights. It is always an Nl x Ni cell array, where Nl is the number
% of network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>), and Ni is the number of network
% inputs (net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>).
%
% The structure defining the properties of the weight going to the ith
% layer from the jth input (or a null matrix []) is located at
% net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j} if net.<a href="matlab:doc nnproperty.net_inputConnect">inputConnect</a>(i,j) is 1 (or 0).
%
% Each input weight has the following properties:
%
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_delays">delays</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initSettings">initSettings</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learn">learn</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnParam">learnParam</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_size">size</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_weightFcn">weightFcn</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_weightParam">weightParam</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_userdata">userdata</a>

% Copyright 2010 The MathWorks, Inc.
