% Neural network layer range property.
% 
% NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_range">range</a>
%
% This read-only property defines the output range of each neuron of
% the ith layer.
%
% It is set to an Si x 2 matrix, where Si is the number of neurons in the
% layer (net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>), and each element in column 1 is less than
% the element next to it in column 2.
%
% Each jth row defines the minimum and maximum output values of the
% layer's transfer function net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a>.

% Copyright 2010 The MathWorks, Inc.
