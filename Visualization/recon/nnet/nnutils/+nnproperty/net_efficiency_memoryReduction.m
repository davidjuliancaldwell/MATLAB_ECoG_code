% Neural network memory reduction efficiency property.
% 
% NET.<a href="matlab:doc nnproperty.net_efficiency">efficiency</a>.<a href="matlab:doc nnproperty.net_efficiency_memoryReduction">memoryReduction</a>
%
% This property can be set to 1 (the default) or any integer greater than
% 1. If set to an integer N, then simulation and error gradient and
% Jacobian calculations will be split in time into N subcalculations by
% groups of samples. This will result in greater time overhead but result
% in reduced memory requirements for storing intermediate values.
%
% For greater memory efficiency set this to higher values.

% Copyright 2010 The MathWorks, Inc.
