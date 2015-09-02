% Neural network outputConnect property.
% 
% NET.<a href="matlab:doc nnproperty.net_outputConnect">outputConnect</a>
%
% This property defines which layers generate network outputs. It can be
% set to any 1 x Nl matrix of Boolean values, where Nl is the number of
% network layers (net.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>). The presence (or absence) of a network
% output from the ith layer is indicated by a 1 (or 0) at
% net.<a href="matlab:doc nnproperty.net_outputConnect">outputConnect</a>(i).
%
% Side Effects:
%
% Any change to this property alters the number of network outputs
% (net.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>) and the presence or absence of structures in the cell
% array of output subobjects (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>).

% Copyright 2010 The MathWorks, Inc.
