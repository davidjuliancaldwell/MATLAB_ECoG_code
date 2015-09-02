function sizes = output_sizes(net)
%OUTPUT_SIZES Output sizes of a neural network

% Copyright 2010-2012 The MathWorks, Inc.

sizes = zeros(net.numOutputs,1);
outputInd = find(net.outputConnect);
for i=1:net.numOutputs
  ii = outputInd(i);
  sizes(i) = net.outputs{ii}.size;
end
