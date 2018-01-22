% Neural network weight initFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a> or NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_initFcn">initFcn</a>
%
% This property defines which <a href="matlab:doc nninitweight">weight initialization function</a>
% is used to initialize the weight matrix (net.<a href="matlab:doc nnproperty.net_IW">IW</a>{i,j} or
% net.<a href="matlab:doc nnproperty.net_LW">LW</a>{i,j}) going to the ith layer from the jth input or layer, if
% the <a href="matlab:doc nninitnetwork">network initialization function</a> net.<a href="matlab:doc nnproperty.net_initFcn">initFcn</a> is <a href="matlab:doc initlay">initlay</a>, and
% the <a href="matlab:doc nninitlayer">layer initialization function</a> net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_initFcn">initFcn</a> is <a href="matlab:doc initwb">initwb</a>.
%
% See also INIT, INITLAY, INITWB

% Copyright 2010 The MathWorks, Inc.
