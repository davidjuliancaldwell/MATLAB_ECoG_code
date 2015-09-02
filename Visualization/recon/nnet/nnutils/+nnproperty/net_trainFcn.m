% Neural network trainFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a>
%
% This property defines the <a href="matlab:doc nntrain">training function</a> to update the network
% when the function <a href="matlab:doc train">train</a> is called.
%
%   [net,tr] = <a href="matlab:doc train">train</a>(net,X,T,Pi,Ai)
%
% Side Effects:
%
% Whenever this property is altered, the network's training parameters
% (net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>) are set to contain the parameters and default values of
% the new function.
%
% See also TRAIN

% Copyright 2010 The MathWorks, Inc.
