function problem = netCheck(net,hints,usesGradient,usesJacobian)

% Copyright 2012 The MathWorks, Inc.

if usesJacobian
  problem = 'GPU supports gradient but not Jacobian <a href="matlab:doc nntrain">backpropagation training</a>.';
  return
end

fcns = nnGPU.netFcns;

for i=1:net.numInputs
  for j=1:numel(net.inputs{i}.processFcns)
    f = net.inputs{i}.processFcns{j};
    nc = net.inputs{i}.processSettings{j}.no_change;
    if isempty(nnstring.match(f,fcns.inputProcessFcns)) && ~nc
      problem = ['Input processing function ' upper(f) ' is not supported with GPU.'];
      return;
    end
  end
end

for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      f = net.inputWeights{i,j}.weightFcn;
      if isempty(nnstring.match(f,fcns.weightFcns))
        problem = ['Weight function ' upper(f) ' is not supported with GPU.'];
        return;
      end
      d = net.inputWeights{i,j}.delays;
      if any(diff(d) ~= 1)
        problem = 'Non-consequtive delays are not supported with GPU.';
        return;
      end
    end
  end

  for j=1:net.numLayers
    if net.layerConnect(i,j)
      f = net.layerWeights{i,j}.weightFcn;
      if isempty(nnstring.match(f,fcns.weightFcns))
        problem = ['Weight function ' upper(f) ' is not supported with GPU.'];
        return;
      end
      d = net.layerWeights{i,j}.delays;
      if any(diff(d) ~= 1)
        problem = 'Non-consequtive delays are not supported with GPU.';
        return;
      end
    end
  end

  f = net.layers{i}.netInputFcn;
  if isempty(nnstring.match(f,fcns.netInputFcns))
    problem = ['Net input function ' upper(f) ' is not supported with GPU.'];
    return;
  end

  f = net.layers{i}.transferFcn;
  if isempty(nnstring.match(f,fcns.transferFcns))
    problem = ['Transfer function ' upper(f) ' is not supported with GPU.'];
    return;
  end

  if net.outputConnect(i)
    for j=1:numel(net.outputs{i}.processFcns)
      f = net.outputs{i}.processFcns{j};
      nc = net.outputs{i}.processSettings{j}.no_change;
      if isempty(nnstring.match(f,fcns.outputProcessFcns)) && ~nc
        problem = ['Output processing function ' upper(f) ' is not supported with GPU.'];
        return;
      end
    end
  end
end

problem = '';
