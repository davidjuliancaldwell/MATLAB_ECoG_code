function flag = needsGradient(net)

% Copyright 2012 The MathWorks, Inc.

flag = false;
if (~isdeployed)
  for i=1:net.numLayers
    for j=find(net.inputConnect(i,:))
    learnFcn = net.inputWeights{i,j}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        flag = true; return
      end
    end
    for j=find(net.layerConnect(i,:))
    learnFcn = net.layerWeights{i,j}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        flag = true; return
      end
    end
    if net.biasConnect(i)
    learnFcn = net.biases{i}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        flag = true; return
      end
    end
  end
end
