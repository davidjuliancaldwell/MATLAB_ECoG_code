function [order,zeroDelayLoop] = layer_order(net)

% Copyright 2010-2012 The MathWorks, Inc.

zeroDelayLoop = false;

% Find zero-delay layer connections
dependancies = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    if any(net.layerWeights{i,j}.delays == 0)
      dependancies(i,j) = 1;
    end
  end
end

% Find layer order
order = zeros(1,net.numLayers);
unordered = ones(1,net.numLayers);
for k=1:net.numLayers
  for i=find(unordered)
    if ~any(dependancies(i,:))
      dependancies(:,i) = 0;
      order(k) = i;
      unordered(i) = 0;
      break;
    end
  end
end

% Return no order if zero delay loop
if any(unordered)
  order = [];
  zeroDelayLoop = true;
end

% Remove layers with no impact on output
outputConnect = net.outputConnect;
unconnected = find(~outputConnect);
numUnconnected = length(unconnected);
for i=1:numUnconnected
  for j = 1:length(unconnected);
    k = unconnected(j);
    if any(net.layerConnect(:,k) & outputConnect')
      outputConnect(k) = true;
      unconnected(j) = [];
      break;
    end
  end
end
