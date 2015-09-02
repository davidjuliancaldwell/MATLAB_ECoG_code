% Neural network numFeedbackDelays property.
% 
% NET.<a href="matlab:doc nnproperty.net_numFeedbackDelays">numFeedbackDelays</a>
%
% This property indicates the number of time steps ahead a dynamic network
% predicts outputs. It is always set to the maximum delay value associated
% with any of the network's outputs (net.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackDelay">feedbackDelay</a>).
%
% This value is used by <a href="matlab:doc preparets">preparets</a> to format time series data properly 
% for specific dynamic networks.
%
% See also PREPARETS

% Copyright 2010 The MathWorks, Inc.
