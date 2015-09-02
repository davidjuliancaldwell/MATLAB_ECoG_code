function num = forward_layer_delays(net)

% Copyright 2010-2012 The MathWorks, Inc.

num = 0;
for i=1:net.numLayers
  if net.outputConnect(i)
    numi = delays_to_layer(net,i,[]);
    if (numi == -1), num = -1;  return; end
    num = max(num,numi);
  end
end

function num = delays_to_layer(net,i,traversed_layers)

if any(traversed_layers == i)
  num = -1; return;
end

num = 0;
traversed_layers(end+1) = i;
for j = 1:net.numLayers
  if net.layerConnect(i,j)
    num_indirect = delays_to_layer(net,j,traversed_layers);
    if (num_indirect == -1), num = -1; return; end
    num_direct = max(net.layerWeights{i,j}.delays);
    num = max(num,num_direct+num_indirect);
  end
end
