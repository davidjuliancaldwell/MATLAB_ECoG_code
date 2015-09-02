% Neural network divideMode property.
% 
% NET.<a href="matlab:doc nnproperty.net_divideMode">divideMode</a>
%
% This property defines the target data dimensions which to divide up when
% the <a href="matlab:doc nndivision">data division function</a> net.<a href="matlab:doc nnproperty.net_divideFcn">divideFcn</a> is called.
%
% Its default value is 'sample' for  static networks and 'time' for
% dynamic networks.
%
% It may also be set to 'sampletime' to divide targets by both sample and
% timestep, 'all' to divide up targets by every scalar value, or 'none'
% to not divide up data at all (in which case all data us used for
% training, none for validation or testing).

% Copyright 2010 The MathWorks, Inc.
