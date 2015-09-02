function d = input_delays(net)
%INPUT_DELAYS Number of delays associated with each neural network input.
%
%  ID = INPUT_DELAYS(NET) returns the maximum input weight delay
%  associated with each input of the network.

% Copyright 2010 The MathWorks, Inc.

d = zeros(net.numInputs,1);
for i = 1:net.numInputs
  for j=1:net.numLayers
    if net.inputConnect(j,i)
      d(i) = max(d(i),max(net.inputWeights{j,i}.delays));
    end
  end
end
