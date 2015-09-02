% Neural network inputConnect property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputConnect">inputConnect</a>
%
% This property defines which layers have weights coming from inputs.
%
% It can be set to any Nl x Ni matrix of Boolean values, where Nl is the
% number of network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>), and Ni is the number of
% network inputs (net.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>). The presence (or absence) of a weight
% going to the ith layer from the jth input is indicated by a 1 (or 0)
% at net.<a href="matlab:doc nnproperty.net_inputConnect">inputConnect</a>(i,j).
%
% Side Effects:
%
% Any change to this property alters the presence or absence of structures
% in the cell array of input weight subobjects (net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>) and the
% presence or absence of matrices in the cell array of input weight
% matrices (net.<a href="matlab:doc nnproperty.net_IW">IW</a>).

% Copyright 2010 The MathWorks, Inc.
