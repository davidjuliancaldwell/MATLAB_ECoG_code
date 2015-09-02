% Neural network numLayers property.
% 
% NET.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>
%
% This property defines the number of layers a network has. It can be set
% to 0 or a positive integer.
%
% Side Effects:
%
% Any change to this property changes the size of each of these Boolean
% matrices that define connections to and from layers:
%
%   net.<a href="matlab:doc nnproperty.net_biasConnect">biasConnect</a>
%   net.<a href="matlab:doc nnproperty.net_inputConnect">inputConnect</a>
%   net.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>
%   net.<a href="matlab:doc nnproperty.net_outputConnect">outputConnect</a>
%
% and changes the size of each cell array of subobject structures whose
% size depends on the number of layers:
%
%   net.<a href="matlab:doc nnproperty.net_biases">biases</a>
%   net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>
%   net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>
%   net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>
%
% and also changes the size of each of the network's adjustable
% parameter's properties:
%
%   net.<a href="matlab:doc nnproperty.net_IW">IW</a>
%   net.<a href="matlab:doc nnproperty.net_LW">LW</a>
%   net.b

% Copyright 2010 The MathWorks, Inc.
