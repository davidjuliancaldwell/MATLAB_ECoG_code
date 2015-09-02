function calcMode = defaultMode(net,calcMode,isParallel)

% Copyright 2012 The MathWorks, Inc.

if (nargin < 2) || isempty(calcMode)
  if nargin < 3, isParallel = false; end
  
  if ~isdeployed && ~isempty(net.trainFcn)
    trainInfo = feval(net.trainFcn,'info');
    usesGradient = trainInfo.usesGradient;
    usesJacobian = trainInfo.usesJacobian;
  else
    usesGradient = false;
    usesJacobian = false;
  end
  
  if ~usesGradient && ~usesJacobian
    % Simulation
    calcMode = nnMex;
    if ~isempty(calcMode.netCheck(net,calcMode.hints,usesGradient,usesJacobian))
      calcMode = nnMATLAB;
    end
  elseif usesGradient
    % Gradient
    if ~isParallel && (net.numWeightElements > 1000) % TEMPORARY SOLUTION TO MEX PERFORMANCE BUG
      calcMode = nnMATLAB;
    else
      calcMode = nnMex;
      if ~isempty(calcMode.netCheck(net,calcMode.hints,usesGradient,usesJacobian))
        calcMode = nnMATLAB;
      end
    end
  else
    % Jacobian
    if ~isParallel && (net.numWeightElements > 180) % TEMPORARY SOLUTION TO MEX PERFORMANCE BUG
      calcMode = nn7;
    else
      calcMode = nnMex;
      if ~isempty(calcMode.netCheck(net,calcMode.hints,usesGradient,usesJacobian))
        calcMode = nn7;
      end
    end
  end

elseif isfield(calcMode.hints,'subcalc')
  if strcmp(calcMode.hints.subcalc.name,'default')
    calcMode.hints.subcalc = nncalc.defaultMode(net,[],strcmp(calcMode.mode,'nnParallel'));
  end
  calcMode.hints.subcalc = nncalc.defaultMode(net,calcMode.hints.subcalc);

elseif isfield(calcMode.hints,'subcalcs')
  for i=1:numel(calcMode.hints.subcalcs)
    calcMode.hints.subcalcs{i} = nncalc.defaultMode(net,calcMode.hints.subcalcs{i});
  end
end
