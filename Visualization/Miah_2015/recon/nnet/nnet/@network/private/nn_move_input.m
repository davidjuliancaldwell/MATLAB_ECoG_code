function net = nn_move_input(net,i,j)
%NN_MOVE_INPUT Move a network input.

% Copyright 2010 The MathWorks, Inc.

if (i == j), return, end

indices = 1:net.numInputs;
indices(i) = [];
indices = [indices(1:(j-1)) i indices(j:end)];
net = nn_reorder_inputs(net,indices);
