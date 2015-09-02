% Neural network numInputs property.
% 
% NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%
% This property defines the number of inputs a network receives. It can be
% set to 0 or a positive integer.
%
% Clarification:
%
% The number of network inputs and the size of a network input are not
% the same thing. The number of inputs defines how many sets of vectors
% the network receives as input. The size of each input (i.e., the number
% of elements in each input vector) is determined by the input size
% (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>).
%
% Most networks have only one input, whose size is determined by the
% problem.
%
% Side Effects:
%
% Any change to this property results in a change in the size of the
% matrix defining connections to layers from inputs (net.<a href="matlab:doc nnproperty.net_inputConnect">inputConnect</a>),
% the cell array of input subobjects (net.<a href="matlab:doc nnproperty.net_inputs">inputs</a>), and the cell array
% of weight values (net.<a href="matlab:doc nnproperty.net_IW">IW</a>).

% Copyright 2010 The MathWorks, Inc.
