function net = unconfigure(net,type,ind)
%UNCONFIGURE Unconfigure network inputs and outputs.
%
%  <a href="matlab:doc unconfigure">unconfigure</a>(net) returns a network with its inputs and output
%  sizes set to zero.  The network is then ready to be configured to
%  new data with <a href="matlab:doc configure">configure</a> or automatically the first time the
%  network is trained with new data.
%
%  <a href="matlab:doc unconfigure">unconfigure</a>(net,'inputs') unconfigures inputs only.
%  <a href="matlab:doc unconfigure">unconfigure</a>(net,'outputs') unconfigures outputs only.
%
%  <a href="matlab:doc unconfigure">unconfigure</a>(net,'inputs',i) unconfigures the inputs defined
%  by indices i. <a href="matlab:doc unconfigure">unconfigure</a>(net,'outputs',i) unconfigures only
%  the outputs indicated by indices i.
%
% See also: CONFIGURE, ISCONFIGURED, TRAIN, VIEW.

% Copyright 2010 The MathWorks, Inc.

switch nargin
  case 0
    error(message('nnet:Args:NotEnough'));
  case 1
    x = cell(net.numInputs,1);
    t = cell(net.numOutputs,1);
    net = configure(net,x,t);
  case 2
    switch lower(type)
      case {'input','inputs'}
        x = cell(net.numInputs,1);
        net = configure(net,'inputs',x);
      case {'output','outputs','target','targets'}
        t = cell(net.numOutputs,1);
        net = configure(net,'targets',t);
      otherwise
        error(message('nnet:unconfigure:UnrecSignalType'));
    end
  case 3
    switch lower(type)
      case {'input','inputs'}
        x = cell(length(ind),1);
        net = configure(net,'inputs',x,ind);
      case {'output','outputs','target','targets'}
        t = cell(length(ind),1);
        net = configure(net,'inputs',t,ind);
      otherwise
        error(message('nnet:unconfigure:UnrecSignalType'));
    end
end
