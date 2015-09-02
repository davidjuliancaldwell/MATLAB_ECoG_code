function broadcast_boiler(fcn)
%BROADCAST_BOILER Copy boilerplate from one function to sibling functions.

% Copyright 2010 The MathWorks, Inc.

fcns = nnfcn.siblings(fcn);
for i=1:length(fcns)
  f = fcns{i};
  if ~strcmp(fcn,f);
    nncode.transfer_boiler(fcn,f);
  end
end
