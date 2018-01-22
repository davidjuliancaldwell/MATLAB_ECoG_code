function y = sim2nndata(x)
%SIM2NNDATA Convert Simulink time-series to neural network data.
%
% SIM2NNDATA(X) takes a Simulink time-series in matrix or structure form
% and returns the time-series in neural network data format.
%
% Here a random Simulink 20-step time-series is created and converted.
%
%   simts = <a href="matlab:doc rands">rands</a>(20,1);
%   nnts = <a href="matlab:doc sim2nndata">sim2nndata</a>(simts)
%
% Here a similar time-series is defined with a Simulink structure and
% converted.
%
%   simts.time = 0:19
%   simts.signals.values = <a href="matlab:doc rands">rands</a>(20,1);
%   simts.dimensions = 1;
%   nnts = <a href="matlab:doc sim2nndata">sim2nndata</a>(simts)
%
% The reverse transform can be done with <a href="matlab:doc nndata2sim">nndata2sim</a>.
%
% See also GENSIM, SETSIMINIT, NNDATA2SIM.

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, error(message('nnet:Args:NotEnough')); end

if isstruct(x)
  y = con2seq(x.signals.values');
elseif isnumeric(x) && (ndims(x) == 2)
  y = con2seq(x');
else
  error(message('nnet:NNData:CannotConvert'));
end
