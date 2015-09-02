function y = tapdelay(x,i,ts,delays)
%TAPDELAY Shift neural network time series data for a tap delay.
%
%  <a href="matlab:doc tapdelay">tapdelay</a>(X,i,TS,delays) takes neural network cell data X, a signal
%  index i, a timestep index and a row vector of tap delays and
%  returns the ith signal in X at timesteps TS - delays.
%
%  Here a random signal X consisting of eight timesteps is defined, and
%  a tap delay with delays of [0 1 4] is simulated at timestep six.
%
%    x = num2cell(rand(1,8));
%    y = <a href="matlab:doc tapdelay">tapdelay</a>(x,1,6,[0 1 4])
%
%  See also PREPARETS.

% Copyright 2010 The MathWorks, Inc.

if nargin < 3,error(message('nnet:Args:NotEnough'));end
x = nntype.data('format',x,'Data');
nntype.index('check',i,'Signal index');
nntype.index('check',ts,'Timestep index');
nntype.delayvec('check',delays,'Delay vector');

if i>size(x,1),error(message('nnet:NNData:SigIndexTooLarge')); end
if ts>size(x,2),error(message('nnet:NNData:TimeIndexTooLarge')); end
if (ts-max(delays))<=0,error(message('nnet:NNData:NegDelayResult')); end

y = cat(1,x{i,ts-delays});
