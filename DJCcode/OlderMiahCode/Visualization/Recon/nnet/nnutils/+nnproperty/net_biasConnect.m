% Neural network biasConnect property.
% 
% NET.<a href="matlab:doc nnproperty.net_biasConnect">biasConnect</a>
%
% This property defines which layers have biases. It can be set to any
% N-by-1 matrix of Boolean values, where Nl is the number of network
% layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>). The presence (or absence) of a bias to the ith
% layer is indicated by a 1 (or 0) at
%
%   net.<a href="matlab:doc nnproperty.net_biasConnect">biasConnect</a>(i)
%
% Side Effects:
%
% Any change to this property alters the presence or absence of structures
% in the cell array of biases (net.<a href="matlab:doc nnproperty.net_biases">biases</a>) and, in the presence or absence
% of vectors in the cell array, of bias vectors (net.<a href="matlab:doc nnproperty.net_b">b</a>).

% Copyright 2010 The MathWorks, Inc.
