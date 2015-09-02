function ok = calc(net,x,xi,ai,t,ew,masks,seed)
%CALC Test simulation, performance, gradient and Jacobian calculations

seed = 19;

% Copyright 2010-2012 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t,ew,masks] = nntest.rand_problem(seed);
end

if nargin == 1, clc, end
disp(' ')
disp(['========== NNTEST.CALC(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,t,ew,masks,seed); disp(' '); end

net = adjust_net(net);

diagram = view(net);

ws = warning('off','parallel:gpu:kernel:NullPointer');
setdemorandstream(seed);
ok = test_calc(net,x,xi,ai,t,ew,masks,seed);
warning(ws);

diagram.setVisible(false)
diagram.dispose

if ok
  result = 'PASSED';
else
  net.name = ['INNACCURATE - ' net.name];
  view(net)
  result = 'FAILED';
end
disp(' ')
disp(['========== NNTEST.CALC(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function net = adjust_net(net)

% ====================================================================

function ok = test_calc(net,X,Xi,Ai,T,EW,MASKS,seed)

net = struct(net);

% ====== DIMENSIONS

if ~isempty(X)
  Q = size(X{1},2);
elseif ~isempty(Xi)
  Q = size(Xi{1},2);
elseif ~isempty(Ai)
  Q = size(Ai{1},2);
elseif ~isempty(T)
  T = size(T{1},2);
else
  Q = 0;
end

TS = nnfast.numtimesteps(X);

% ====== TOLERANCES ======

% TODO - Put tolerances into calculation modes

% Base Tolerances
tolerancesAnalytic.abs = 1e-12 * sqrt(TS);
tolerancesAnalytic.rel = 1e-8 * sqrt(TS);

tolerancesNumeric.abs = 1e-9 * sqrt(TS);
tolerancesNumeric.rel = 1e-4 * sqrt(TS);

% Pass individual derivative failures if they happen after
% successful individual derivative with extremely large value.
passIndividualTolerance = 1e29;

tolerancesSkipNumeric.abs = tolerancesAnalytic.abs;
tolerancesSkipNumeric.rel = 1;

% ====== DATA ======

data.X = X;
data.Xi = Xi;
data.Pc = {};
data.Pd = {};
data.Ai = Ai;
data.T = T;
data.EW = EW;
data.Q = Q;
data.TS = TS;
data.train.enabled = true;
data.train.mask = MASKS{1};
data.val.enabled = true;
data.val.mask = MASKS{2};
data.test.enabled = true;
data.test.mask = MASKS{3};
data.TSu = data.TS;
data.Qu = data.Q;

% ======= CALC MODES ======

simulationModes = { ...
  nn7 ...
  nnSimple ...
  nnMATLAB ...
  nnMemReduc ...
  nnMex ...
  nnParallel('subcalc',nnMATLAB) ...
  nnParallel('subcalc',nnMex) ...
  nnGPU ...
  nnParallel('subcalc',nnGPU)
  };

analyticalModes = { ...
  nn7('direction','default') ...
  nn7('direction','backward') ...
  nn7('direction','forward') ...
  nnSimple('direction','backward') ...
  nnSimple('direction','forward') ...
  nnMATLAB('direction','backward') ...
  nnMATLAB('direction','forward') ...
  nnMemReduc ...
  nnMex('direction','backward') ...
  nnMex('direction','forward') ...
  nnParallel('subcalc',nnMATLAB) ...
  nnParallel('subcalc',nnMex) ...
  nnGPU ...
  nnParallel('subcalc',nnGPU)
  };

numericalModes = { ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-7) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-7) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-7.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-7.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-8.0) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-8.0) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-6.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-6.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-6.0) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-6.0) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-5.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-5.5) ...
  nn2Point('subcalc',nnMATLAB,'direction','positive','delta',10^-5.0) ...
  nn2Point('subcalc',nnMATLAB,'direction','negative','delta',10^-5.0) ...
  nn5Point('subcalc',nnMATLAB) ...
  nnNPoint('subcalc',nnMATLAB) ...
  };

% ====== CALC TESTS ======

simTests = {...
  'getwb'; ...
  'setwb'; ...
  'y'; ...
  'trainPerf'; ...
  'trainValTestPerfs'; ...
  };

calcTests = {...
  'grad'; ...
  'perfsGrad'; ...
  'perfsJEJJ'; ...
  };

% ====== RUN ======

ok = true;
space = ' ';

% SIMULATION TESTS
for i=1:numel(simTests)
  calcTest = simTests{i};
  disp(' ')
  disp(['TESTING: calcMode.' calcTest])
  v1 = [];
  vv1 = [];
  
  for j=1:numel(simulationModes)
    calcMode = simulationModes{j};
    calcName = calcMode.name;
    fprintf(['  ' calcName ': ' space(ones(1,(30-length(calcName))))])
    reset(RandStream.getGlobalStream)
    
    calcMode = nncalc.defaultMode(net,calcMode);
    if ~isempty(calcMode.netCheck(net,calcMode.hints,false,false))
      disp('Unsupported'), continue
    end

    [calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
    [v,vv,failstr] = nntest.calc1(calcMode,calcNet,calcData,calcHints,calcTest);
    
    [fail,basicErr,v1,vv1] = check_results(calcName,v,vv,v1,vv1,failstr,j,tolerancesAnalytic); 
  end
  if fail, ok = false; end
end
if ~ok, return; end

% DERIVATIVE TESTS
failedAnalytic = false;
for i=1:numel(calcTests)
  calcTest = calcTests{i};
  disp(' ')
  disp(['TESTING: calcMode.' calcTest])
  
  % ENFORCE ASSUMPTION: Gradient & Jacobian require finite inputs
  if strcmp(calcTest,'grad')
    for k=1:numel(data.X)
      data.X{k}(isnan(data.X{k})) = 0;
    end
    for k=1:numel(data.Xi)
      data.Xi{k}(isnan(data.Xi{k})) = 0;
    end
    for k=1:numel(data.Ai)
      data.Ai{k}(isnan(data.Ai{k})) = 0;
    end
  end
  
  % ENFORCE ASSUMPTION: Jacobian only works with MSE, SSE
  if strcmp(calcTest,'perfsJEJJ')
    if ~(strcmp(net.performFcn,'mse') || strcmp(net.performFcn,'sse'))
      normalization = net.performParam.normalization;
      regularization = net.performParam.regularization;
      net = network(net);
      if rand > 0.5
        net.performFcn = 'mse';
      else
        net.performFcn = 'sse';
      end
      net.performParam.normalization = normalization;
      net.performParam.regularization = regularization;
      net = struct(net);
    end
  end
    
  % TEST ANALYTICAL DERIVATIVES
  basicErrors = false;
  for j=1:numel(analyticalModes)
    calcMode = analyticalModes{j};
    calcName = calcMode.name;
    fprintf(['  ' calcName ': ' space(ones(1,(30-length(calcName))))])
    reset(RandStream.getGlobalStream)
    
    calcMode = nncalc.defaultMode(net,calcMode);
    usesGradient = ~isempty(nnstring.first_match(calcTest,{'grad','perfsGrad'}));
    usesJacobian = strcmp(calcTest,'perfsJEJJ');
    if ~isempty(calcMode.netCheck(net,calcMode.hints,usesGradient,usesJacobian))
      disp('Unsupported')
      continue
    end

    [calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
    [v,vv,failstr] = nntest.calc1(calcMode,calcNet,calcData,calcHints,calcTest);
    
    [fail,basicErr,v1,vv1] = check_results(calcName,v,vv,v1,vv1,failstr,j,tolerancesAnalytic); 
    if fail
      failedAnalytic = true; %keyboard
      if basicErr, basicErrors = true; end
    end
  end
  if basicErrors, ok = false; return, end
    
  % Test Jacobian against Gradient
  if strcmp(calcTest,'perfsGrad')
    gWB_grad = vv1{1};
    MSE_or_SSE_grad = ~isempty(nnstring.match(net.performFcn,{'mse','sse'}));
  elseif strcmp(calcTest,'perfsJEJJ') && MSE_or_SSE_grad
    JE = vv1{1};
    gWB_jac = -2*JE;
    calcName2 = 'Jacobian vs. Gradient';
    fprintf(['  ' calcName2 ': ' space(ones(1,(30-length(calcName2))))])
    [fail,basicErr] = check_results(calcName2,gWB_jac,{},gWB_grad,{},failstr,j,tolerancesAnalytic);
    if fail || basicErr
      ok = false; return;
    end
  end
  
  % TEST NUMERIC DERIVATIVES
  disp('  --')
  failedNumeric = true;
  analytic = v1;
  numericMax = -inf(size(analytic));
  numericMin = inf(size(analytic));
  numeric = NaN(size(analytic));
  for j=1:numel(numericalModes)
    calcMode = numericalModes{j};
    calcName = calcMode.name;
    fprintf(['  ' calcName ': ' space(ones(1,(30-length(calcName))))])
    reset(RandStream.getGlobalStream)
      
    calcMode = nncalc.defaultMode(net,calcMode);
    usesGradient = ~isempty(nnstring.first_match(calcTest,{'grad','perfsGrad'}));
    usesJacobian = strcmp(calcTest,'perfsJEJJ');
    if ~isempty(calcMode.netCheck(net,calcMode.hints,usesGradient,usesJacobian))
      disp(' ')
      continue
    end

    [calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
    [v,vv,failstr] = nntest.calc1(calcMode,calcNet,calcData,calcHints,calcTest);
    
    % Accumulate best numeric estimates so far
    numericMax = max(numericMax,v);
    numericMin = min(numericMin,v);
    bounded = (numericMax > analytic) & (numericMin < analytic);
    numeric(bounded) = analytic(bounded);
    for k=1:numel(analytic)
      if isnan(numeric(k)) || (abs(analytic(k)-v(k)) < abs(analytic(k)-numeric(k)))
        numeric(k) = v(k);
      end
    end
    
    [fail,basicErr,v1,vv1] = check_results(calcName,numeric,vv,v1,vv1,failstr,0,tolerancesNumeric);

    if ~fail
      failedNumeric = false;
      break;
    end
    if basicErr, ok = false; return; end
  end
  
  if ~failedAnalytic && ~failedNumeric
    continue
  end
  
  % TEST INDIVIDUAL GRADIENT DERIVATIVES
  disp('--')
  disp(' ')
  disp('ATTEMPTING TO IDENTIFY DERIVATIVE PROBLEM IN INDIVIDUAL BLOCKS')
  disp(' ')
  [numericProblems,analyticProblems,discont,ignore,maxderiv] = nntest.deriv(net,data.X,data.Xi,data.Ai,data.T,data.EW,data.train.mask);
 
  disp(' ')
  if failedAnalytic && ~isempty(analyticProblems)
    disp('*** FAILED GLOBAL AND INDIVIUDAL ANALYTICAL DERIVATIVE ***')
    ok = false;
    return
  elseif ~isempty(analyticProblems)
    disp('*** PASSED GLOBAL. BUT FAILED INDIVIUDAL ANALYTICAL DERIVATIVE ***')
    ok = false;
    return
  elseif ~isempty(discont)
    disp('*** SKIPPING PROBLEM ***')
    disp('*** KNOWN DISCONTINUITY ***')
    return
  elseif ~isempty(ignore)
    disp('*** SKIPPING PROBLEM ***')
    disp('*** KNOWN NUMERICAL DERIVATIVE FAILURE ***')
    return
  elseif (maxderiv > passIndividualTolerance)
    disp(' ')
    disp('*** SKIPPING PROBLEM ***')
    disp('*** LARGE DERIVATIVE PRECEEDING DERIVATIVE FAILURE ***')
    return
  elseif ~isempty(numericProblems)
    ok = false;
    disp(' ')
    disp('*** NUMERICAL FAILURE ***')
    return
  end
  
  disp(' ')
  disp('NO PROBLEM FOUND IN INDIVIDUAL BLOCKS')
  
  % If failed analytical tests then no excuse
  if failedAnalytic
    ok = false;
    return
  end
  
  % TEST FINAL NUMERIC GRADIENT MODE
  disp(' ')
  disp('--')
  calcMode = nnNPoint;
  calcName = calcMode.name;
  disp(['  ' calcName ': ' num2str(net.numWeightElements) ' weights and biases...'])
  disp(' ')
  reset(RandStream.getGlobalStream)

  [calcMode,calcNet,calcData,calcHints] = nncalc.setup1(calcMode,net,data);
  [v,vv,failstr] = nntest.calc1(calcMode,calcNet,calcData,calcHints,calcTest);

  disp(' ')
  disp(' ')
  fprintf(['  ' calcName ': '])
  [fail,basicErr,v1,vv1] = check_results(calcName,v,vv,v1,vv1,failstr,0,tolerancesNumeric); 

  if fail
    ok = false;
  end
  return; % Skip Jacobian for difficult numerical cases
end

function [fail,basicErr,v1,vv1] = check_results(calcName,v,vv,v1,vv1,failstr,j,tolerances)
fail = false; % Accuracy, NaN or size failure
basicErr = false; % NaN or Size failure

    
if (j==1)
  v1 = v;
  vv1 = vv;
end

if iscell(v1)
  V1 = cell2mat(v1);
else
  V1 = v1;
end
NaN1 = isnan(V1);
mag = sqrt(sum(V1(~NaN1).^2));

space = ' ';
if ~isempty(failstr)
  fail = true;
  e = ['FAILURE:  ' failstr];
  basicErr = true;
elseif (j==1)
  mag_str = num2str(mag,5);
  mag_str = [space(ones(1,26-numel(mag_str))) mag_str];
  e = ['Baseline, ' mag_str ' mag'];
else
  v2 = v;
  if iscell(v1)
    V1 = cell2mat(v1);
    V2 = cell2mat(v2);
  else
    V1 = v1;
    V2 = v2;
  end
  size1 = size(V1);
  size2 = size(V2);
  if isempty(V1), V1 = 0; end
  if isempty(V2), V2 = 0; end
  NaN2 = isnan(V2);
  if any(size1 ~= size2)
    fail = true;
    e = 'INACCURATE, Mismatched sizes';
    basicErr = true;
  elseif any(NaN1~=NaN2)
    fail = true;
    e = 'INACCURATE, Mismatched NaNs'; [V1(:) V2(:)]
    basicErr = true;
  else
    diff = V1(:)-V2(:);
    diff(NaN1) = 0;
    diff_abs = sqrt(sum(diff(~NaN1).^2));
    if (mag == 0), mag = 1; end
    diff_rel = diff_abs / mag;

    fail1 = diff_abs > tolerances.abs;
    fail2 = diff_rel > tolerances.rel;
    fail = (fail1 && fail2);
    if fail, [V1(:) V2(:) (V1(:)./V2(:))] %%%%
      e1 =  'INACCURATE, ';
    else
      e1 = 'Accurate,   ';
    end
    
    tol_abs_str = num2str(tolerances.abs);
    diff_abs_str = num2str(diff_abs,5);
    indent = repmat(' ',1,22-numel(tol_abs_str)-numel(diff_abs_str));    
    if fail1
      e2 = [indent diff_abs_str '>' tol_abs_str ' ABS'];
    else
      e2 = [indent diff_abs_str '<' tol_abs_str ' abs'];
    end
    
    tol_rel_str = num2str(tolerances.rel);
    diff_rel_str = num2str(diff_rel,5);
    indent = repmat(' ',1,24-numel(tol_rel_str)-numel(diff_rel_str));
    if fail2
      e3 = [indent diff_rel_str '>' tol_rel_str ' REL'];
    else
      e3 = [indent diff_rel_str '<' tol_rel_str ' rel'];
    end
    e = [e1 ' ' e2 ', ' e3];
  end
end
disp(e)
