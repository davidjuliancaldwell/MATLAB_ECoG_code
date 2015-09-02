% Neural network biases property.
% 
% NET.<a href="matlab:doc nnproperty.net_biases">biases</a>
%
% This property holds structures of properties for each of the network's
% biases. It is always an Nl x 1 cell array, where Nl is the number of
% network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>).
%
% The structure defining the properties of the bias associated with the
% ith layer (or a null matrix []) is located at net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i} if
% net.<a href="matlab:doc nnproperty.net_biasConnect">biasConnect</a>(i) is 1 (or 0).
%
% Each bias structure has the following properties:
%
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_initFcn">initFcn</a>
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learn">learn</a>
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learnFcn">learnFcn</a>
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learnParam">learnParam</a>
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_size">size</a>
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_userdata">userdata</a>

% Copyright 2010 The MathWorks, Inc.
