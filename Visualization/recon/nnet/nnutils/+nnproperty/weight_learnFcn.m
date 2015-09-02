% Neural network weight learnFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a> or NET.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>{i,j}.<a href="matlab:doc nnproperty.weight_learnFcn">learnFcn</a>
%
% This property defines the <a href="matlab:doc nnlearn">learning function</a> used to update
% the weight matrix (net.<a href="matlab:doc nnproperty.net_IW">IW</a>{i,j}) going to the ith layer from the jth input
% during training, if the network <a href="matlab:doc nntrain">training function</a> (net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a>) is a
% weight/bias training function such as <a href="matlab:doc trainb">trainb</a> or a weight/bias
% <a href="matlab:doc nnadapt">adapt function</a> such as <a href="matlab:doc adaptwb">adaptwb</a>.
%
% For a list of functions, type
%
%   help nnlearn
%
% Side Effects:
%
% Whenever this property is altered, the weights learning parameters
% (net.<a href="matlab:doc nnproperty.net_inputWeights">inputWeights</a>{i}.<a href="matlab:doc nnproperty.weight_learnParam">learnParam</a> or net.<a href="matlab:doc nnproperty.net_layerWeights">layerWeights</a>.<a href="matlab:doc nnproperty.weight_learnParam">learnParam</a>) are set
% to contain the fields and default values of the new function.
%
% See also trainb, trainbu, trainc, trainr, trainru, trains, adaptwb
  
% Copyright 2010 The MathWorks, Inc.
