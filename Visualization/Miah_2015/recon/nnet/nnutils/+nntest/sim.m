function ok = sim(net,x,xi,ai,t,ew,mask,seed)
%SIM Test command line, Simulink and RTW simulation code

% Copyright 2010-2012 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai] = nntest.rand_problem(seed);
elseif nargin == 5
  seed = t;
end

if nargin == 1, clc, end
disp(' ')
disp(['========== NNTEST.SIM(' num2str(seed) ') Testing...'])
disp(' ')
if nargin == 1, nntest.disp_problem(net,x,xi,ai,seed); disp(' '); end

diagram = view(net);

setdemorandstream(seed);
ok = test_sim(net,x,xi,ai);

diagram.setVisible(false)
diagram.dispose

if ok, result = 'PASSED'; else result = 'FAILED'; end
disp(' ')
disp(['========== NNTEST.SIM(' num2str(seed) ') *** ' result ' ***'])
disp(' ')

% ====================================================================

function ok = test_sim(net,x,xi,ai)

TS = nnfast.numtimesteps(x);
Q = nnfast.numsamples(x);

absTolerance = 1e-13 * sqrt(TS);
relTolerance = 1e-12 * sqrt(TS);

% ====== COMMAND LINE TESTS ======

baseMode = nn7;

testModes = {...
  nn7 ...
  nnSimple ...
  nnMATLAB ...
  nnMemReduc ...
  nnMex ...
  nnParallel('subcalc',nnMATLAB) ...
  nnParallel('subcalc',nnMex) ...
  nnGPU ...
  nnParallel('subcalc',nnGPU) ...
  };

disp('COMMAND LINE:')
disp(' ')

[y,xf,af] = sim(net,x,xi,ai,baseMode);
ym = cell2mat(y);
xfm = cell2mat(xf);
afm = cell2mat(af);
v = [ym(:); xfm(:); afm(:)];
v(isnan(v)) = 0;
  
disp(['SIM(NET,X,Xi,Ai) called with calculation mode: ' baseMode.name]);
disp(' ')

for i=1:numel(testModes)
  calcMode = testModes{i};
  calcName = calcMode.mode;
  
  msg = calcMode.netCheck(net,calcMode.hints,false,false);
  if ~isempty(msg)
    disp([calcMode.name ' (unsupported network)'])
    continue
  end
  [y2,xf2,af2] = sim(net,x,xi,ai,calcMode);
  
  ynan = isnan(cell2mat(y));
  ynan2 = isnan(cell2mat(y2));
  xfnan = isnan(cell2mat(xf));
  xfnan2 = isnan(cell2mat(xf2));
  afnan = isnan(cell2mat(af));
  afnan2 = isnan(cell2mat(af2));
  
  if (ndims(y2)~=ndims(y)) || any(size(y2)~=size(y)) || any(any(ynan ~= ynan2))
    disp(['Inconsistent Y, calculation mode: ' calcName])
    ok = false;
    return
  end
  if (ndims(xf2)~=ndims(xf)) || any(size(xf2)~=size(xf)) || any(any(xfnan ~= xfnan2))
    disp(['Inconsistent Xf, calculation mode: ' calcName])
    ok = false;
    return
  end 
  if (ndims(af2)~=ndims(af)) || any(size(af2)~=size(af)) || any(any(afnan ~= afnan2))
    disp(['Inconsistent Af, calculation mode: ' calcName])
    ok = false;
    return
  end 
  
  ym2 = cell2mat(y2);
  xfm2 = cell2mat(xf2);
  afm2 = cell2mat(af2);
  v2 = [ym2(:); xfm2(:); afm2(:)];
  v2(isnan(v2)) = 0;

  mag = sum(sum(abs(v)));
  if mag == 0, mag = 1; end
  abs_diff = max(max(abs(v2-v)));
  if isempty(abs_diff), abs_diff = 0; end
  rel_diff = abs_diff / mag;
  ok = (abs_diff < absTolerance) || (rel_diff < relTolerance);

  if ok
    errstr = '';
  else
    errstr = '  <<< FAILURE';
  end
  if (abs_diff < absTolerance);
    disp([calcMode.name ' abs error  = ' num2str(abs_diff) ' < ' num2str(absTolerance)])
  else
    disp([calcMode.name ' abs error  = ' num2str(abs_diff) ' > ' num2str(absTolerance) errstr])
  end
  if (rel_diff < relTolerance);
    disp([calcMode.name ' rel error  = ' num2str(rel_diff) ' < ' num2str(relTolerance)])
  else
    disp([calcMode.name ' rel error  = ' num2str(rel_diff) ' > ' num2str(relTolerance) errstr])
  end
  disp(' ')
end

% ====== PRUNE ZERO SIZED INPUTS, LAYERS and OUTPUTS  ======

% Remove zero sized and unused inputs, layers, outputs and weights
[net2,PI,PL,PO] = prune(net);
[x2,xi2,ai2] = prunedata(net2,PI,PL,PO,x,xi,ai);

% Replace non-finite data with random values
for i=1:numel(x2)
  ind = find(~isfinite(x2{i}));
  x2{i}(ind) = rands(1,length(ind));
end
for i=1:numel(xi2)
  ind = find(~isfinite(xi2{i}));
  xi2{i}(ind) = rands(1,length(ind));
end
for i=1:numel(ai2)
  ind = find(~isfinite(ai2{i}));
  ai2{i}(ind) = rands(1,length(ind));
end

% ====== SKIP SIMULINK IF INCOMPATIBLE WITH TEST ======

disp('SIMULINK:')
disp(' ')

% Skip Unsupported Networks
skip = simulink_check(net);
if isempty(skip) && (TS==0)
  skip = 'Zero timestep problem';
elseif (Q==0)
  skip = 'Zero sample problem.';
elseif isempty(x2) && isempty(xi2) && isempty(ai2)
  skip = 'Empty data problem after pruning.';
end
if ~isempty(skip)
  disp(['Skipping SIMULINK and RTW Tests: ' skip]);
  disp(' ')
  ok = true;
  return
end

% ====== SIMULINK TESTS ======

y2 = sim(net2,x2,xi2,ai2);

% Generate Network
[sysName,networkName] = gensim(net2,'Name','GENSIM_Test',...
  'InputMode','workspace','OutputMode','workspace',...
  'SolverMode','discrete');
pause(0.05)

disp('GENSIM(NET) called.');
disp(' ')

% Simulate Network
set_param(getActiveConfigSet(sysName),...
  'StartTime','0','StopTime',num2str(TS-1),...
  'ReturnWorkspaceOutputs','on');

outputSizes = zeros(net2.numOutputs,1);
outputInd = find(net2.outputConnect);
for i=1:net2.numOutputs
  outputSizes(i) = net2.outputs{outputInd(i)}.size;
end

ys = nndata(outputSizes,Q,TS,0);
if (net2.numOutputs > 0) && (Q > 0) && (TS > 0)
  for q = 1:Q
    
    % Setup inputs
    for i = 1:net2.numInputs
      x2_sim = nndata2sim(x2,i,q);
      x2_mat = sim2nndata(x2_sim);
      if any(x2_mat{1} ~= x2{i}(:,q))
        disp('FAILURE: Inconsistent Simulink to NN data conversion.');
        ok = false;
        return;
      end
      assignin('base',['x' num2str(i)],x2_sim);
    end
    
    % Setup input and layer delays states
    setsiminit(sysName,networkName,net2,xi2,ai2,q);
    
    % Verify states are installed properly
    [xi3,ai3] = getsiminit(sysName,networkName,net2);
    if any(abs(size(xi3) - size(xi2))>1e-10)
      disp('FAILURE: Inconsistent set/get of simulink input delay states.');
      ok = false;
      return;
    end
    for i=1:numel(xi3)
      if any(abs(xi2{i}(:,q) - xi3{i})>1e-10 & ~isnan(xi3{i}))
        disp('FAILURE: Inconsistent set/get of simulink input delay states.');
        ok = false;
        return;
      end
    end
    if any(abs(size(ai3) - size(ai2))>1e-10)
      disp('Inconsistent set/get of simulink layer delay states.');
      ok = false;
      return;
    end
    for i=1:numel(ai3)
      if any(abs(ai2{i}(:,q) - ai3{i})>1e-10 & ~isnan(ai3{i}))
        disp('FAILURE: Inconsistent set/get of simulink layer delay states.');
        ok = false;
        return;
      end
    end
    
    % Simulate system
    simOut = sim(sysName);
    
    % Get outputs
    yq = cell(net2.numOutputs,TS);
    for i = 1:net2.numOutputs
      yq(i,:) = con2seq(simOut.find(['y' num2str(i)])');
    end
    ys = nnfast.setsamples(ys,q,yq);
    
    % Get final input and layer delay states
    [xf,af] = getsiminit(sysName,networkName,net2);
    
  end
end

% Compare Command-Line and Simulink Outputs
mag = sum(sum(abs(cell2mat(y2))));
if mag == 0, mag = 1; end
abs_diff = max(max(abs(cell2mat(y2) - cell2mat(ys))));
if isempty(abs_diff), abs_diff = 0; end
rel_diff = abs_diff / mag;
ok = (abs_diff < absTolerance) || (rel_diff < relTolerance);

disp(['Simulink mag output  = ' num2str(mag)])
if ok
  errstr = '';
else
  errstr = '  <<< FAILURE';
end
if (abs_diff < absTolerance);
  disp(['Simulink abs error  = ' num2str(abs_diff) ' < ' num2str(absTolerance)])
else
  disp(['Simulink abs error  = ' num2str(abs_diff) ' > ' num2str(absTolerance) errstr])
end
if (rel_diff < relTolerance);
  disp(['Simulink rel error  = ' num2str(rel_diff) ' < ' num2str(relTolerance)])
else
  disp(['Simulink rel error  = ' num2str(rel_diff) ' > ' num2str(relTolerance) errstr])
end
disp(' ')

% ====== CLOSE =====

% Clear inputs from workspace
for i = 1:net2.numInputs
  evalin('base',['clear x' num2str(i)]);
end

% Close Simulink system
close_system(sysName,0);
close_system('neural',0);

pause(0.05)
    
% ====== RTW TESTS ======

%disp('RTW:')

%disp('RTW untested.')

function err = simulink_check(net)
  
% Input processing functions must support Simulink
for i=1:net.numInputs
  input = net.inputs{i};
  for j=1:length(input.processFcns)
    err = feval([input.processFcns{j} '.simulinkParameters'],input.processSettings{j});
    if ischar(err), return; end
  end
end

% Transfer functions must support Simulink
for i=1:net.numLayers
  layer = net.layers{i};
  err = feval(layer.transferFcn,'simulinkParameters',...
    layer.size,layer.transferParam);
  if ischar(err), return; end
end

% Net input functions must support Simulink
for i=1:net.numLayers
  layer = net.layers{i};
  err = feval(layer.netInputFcn,'simulinkParameters',layer.netInputParam);
  if ischar(err), return; end
end

% Weight functions must support Simulink
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      weight = net.inputWeights{i,j};
      err = feval(weight.weightFcn,'simulinkParameters',weight.weightParam);
      if ischar(err), return; end
    end
  end
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      weight = net.layerWeights{i,j};
      err = feval(weight.weightFcn,...
        'simulinkParameters',weight.weightParam);
      if ischar(err), return; end
    end
  end
end

% Output processing functions must support Simulink
for i = find(net.outputConnect)
  output = net.outputs{i};
  for j=1:length(output.processFcns)
    err = feval(output.processFcns{j},...
      'simulinkParametersReverse',output.processSettings{j});
    if ischar(err), return; end
  end
end

err = '';
  
% ====================================================================
