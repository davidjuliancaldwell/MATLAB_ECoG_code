function y = nndata2sim(x,i,q)
%NNDATA2SIM Convert neural network data to Simulink time-series.
%
% <a href="matlab:doc nndata2sim">nndata2sim</a>(X,I,Q) takes neural network data X consisting of an MxTS
% cell array (where M is the number of signals and TS the number of
% timesteps), where each element of X is NixQ (where Ni is the number
% of elements in the ith signal and Q is the number of timeseries).
%
% <a href="matlab:doc nndata2sim">nndata2sim</a> return the Qth timeseries of the Ith signal into
% a Simulink structure with these fields:
%
%   Y.time = 0:(TS-1)
%   y.signals.values = ith/qth time series data
%   y.signals.dimensions = number of elements in ith signal
%
% I and Q are optional and have default values of 1.
%
% Here random neural network data is created with two signals having
% 4 and 3 elements respectively, over 10 timesteps.  Three such series
% are created.
%
%   x = <a href="matlab:doc nndata">nndata</a>([4;3],3,10);
%
% Now the second signal of the first series is converted to Simulink form.
%
%   y_2_1 = <a href="matlab:doc nndata2sim">nndata2sim</a>(x,2,1)
%
% See also GENSIM, SETSIMINIT, GETSIMINIT.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, error(message('nnet:Args:NotEnough')); end
x = nntype.data('format',x,'Data X');
if nargin < 2, i = 1; end
if nargin < 3, q = 1; end
nntype.index('check',i,'Signal index I');
nntype.index('check',q,'Sample/Time-series index J');

[N,Q,TS,M] = nnsize(x);
if (i>M), error(message('nnet:NNData:IndexExceedsXSignals')); end
if (q>Q), error(message('nnet:NNData:IndexExceedsXSamples')); end

ni = N(i);
xiq = nnfast.getsamples(x(i,:),q);

y.time = 0:(TS-1);
y.signals.values = cell2mat(xiq)';
y.signals.dimensions = ni;
