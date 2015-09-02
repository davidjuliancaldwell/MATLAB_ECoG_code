% Neural network layerConnect property.
% 
% NET.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>
%
% This property defines which layers have weights coming from other
% layers. It can be set to any Nl x Nl matrix of Boolean values, where Nl
% is the number of network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>). The presence
% (or absence) of a weight going to the ith layer from the jth layer is
% indicated by a 1 (or 0) at
%
%   net.<a href="matlab:doc nnproperty.net_layerConnect">layerConnect</a>(i,j)
%
% Side Effects:
%
% Any change to this property alters the presence or absence of structures
% in the cell array of layer weight subobjects (net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>) and the
% presence or absence of matrices in the cell array of layer weight
% matrices (net.<a href="matlab:doc nnproperty.net_LW">LW</a>).

% Copyright 2010 The MathWorks, Inc.
