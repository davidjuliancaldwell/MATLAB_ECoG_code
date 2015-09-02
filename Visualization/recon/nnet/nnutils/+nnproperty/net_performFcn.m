% Neural network performFcn property.
% 
% NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a>
%
% This property defines the <a href="matlab:doc nnperformance">performance function</a> used to measure a
% network's usefulness during training with <a href="matlab:doc train">train</a> and for direct
% performance calculations with <a href="matlab:doc perform">perform</a>.
%
%   [net,tr] = <a href="matlab:doc train">train</a>(NET,P,T,Pi,Ai,EW)
%   perf = <a href="matlab:doc perform">perform</a>(NET,X,Y,EW)
%
% Side Effects:
%
% Whenever this property is altered, the network's performance parameters
% (net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>) are set to contain the parameters and default values
% of the new function.
%
% See also TRAIN, PERFORM

% Copyright 2010 The MathWorks, Inc.
