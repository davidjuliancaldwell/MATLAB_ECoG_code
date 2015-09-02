% Neural network cache delayed inputs efficiency property.
% 
% NET.<a href="matlab:doc nnproperty.net_efficiency">efficiency</a>.<a href="matlab:doc nnproperty.net_efficiency_cacheDelayedInputs">cacheDelayedInputs</a>
%
% This property can be set to true (the default) or false. If true then the
% delayed inputs of each input weight are calculated once during training
% and reused, instead of recalculated each time they are needed. This
% results in faster training, but at the expense of memory efficiency.
%
% For greater memory efficiency at the cost of speed for dynamic networks
% set this property to false.
%
% See also TRAIN

% Copyright 2010 The MathWorks, Inc.
