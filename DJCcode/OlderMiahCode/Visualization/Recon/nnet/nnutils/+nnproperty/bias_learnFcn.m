% Neural network biaslearnFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learnFcn">learnFcn</a>
%
% This property defines which <a href="matlab:doc nnlearn">learning function</a> is used to update
% the ith layer's bias vector (net.<a href="matlab:doc nnproperty.net_b">b</a>{i}) during training, if the network
% training function is a weight/bias training function such as <a href="matlab:doc trainb">trainb</a>
% or a weight/bias adapt function such as <a href="matlab:doc
% adaptwb">adaptwb</a>.
%
% Side Effects:
%
% Whenever this property is altered, the biases learning parameters
% (net.<a href="matlab:doc nnproperty.net_biases">biases</a>{i}.<a href="matlab:doc nnproperty.bias_learnParam">learnParam</a>) are set to contain the fields and default
% values of the new function.
%
% See also TRAINB, TRAINBU, TRAINC, TRAINR, TRAINRU, TRAINS, ADAPTWB

% Copyright 2010 The MathWorks, Inc.
