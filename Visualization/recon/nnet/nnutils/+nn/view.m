function out1 = view(net)

% Copyright 2010 The MathWorks, Inc.

if isnumeric(net) && isscalar(net)
  net = nntest.rand_net(net);
end

diagram = nnjava.tools('view',net);
if nargout > 0, out1 = diagram; end


% TODO - Increase transfer function minimum height
% For example, view network with layer with one-input, no-bias

% TODO - Allow Scaling
% TODO - Show processing blocks (each?)
