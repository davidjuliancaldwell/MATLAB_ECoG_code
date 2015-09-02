function [out1,analyticProblems,discont,ignore,maxderiv] = deriv(net,X,Xi,Ai,T,EW,MASK)
%DERIV Test network subfunction derivatives.

% Copyright 2010-2012 The MathWorks, Inc.

% Network and Data Problem
if nargin == 1
  seed = net;
  setdemorandstream(seed);
  [net,X,Xi,Ai,T,EW,MASKS] = nntest.rand_problem(seed);
  MASK = MASKS{1};
end
[numericProblems,analyticProblems,discont,ignore,maxderiv] = deriv1(net,X,Xi,Ai,T,EW,MASK);

if ~isempty(numericProblems)
  disp(' ')
  disp('NUMERICAL PROBLEMS:')
  for i=1:length(numericProblems)
    disp(numericProblems{i})
  end
end
if ~isempty(analyticProblems)
  disp(' ')
  disp('ANALYTICAL PROBLEMS:')
  for i=1:length(analyticProblems)
    disp(analyticProblems{i})
  end
end
if ~isempty(discont)
  disp(' ')
  disp('DISCONTINUITIES:')
  for i=1:length(discont)
    disp(discont{i})
  end
end
if ~isempty(ignore)
  disp(' ')
  disp('KNOWN PROBLEMS:')
  for i=1:length(ignore)
    disp(ignore{i})
  end
end

if nargout > 0
  out1 = numericProblems;
  return
end

disp(' ')
if isempty(problems)
  disp('PASSED.')
elseif ~isempty(discont) || ~isempty(ignore)
  disp('FAILED, BUT DISCONTINUITY OR KNOWN PROBLEM IDENTIFIED.')
else
  disp('FAILED')
end
disp(' ')

function [numericProblems,analyticProblems,discont,ignore,maxderiv] = deriv1(net,X,Xi,Ai,T,EW,MASK)

maxderiv = 0;
numericProblems = {};
analyticProblems = {};
discont = {};
ignore = {};
N = 7; % For forward/backward prop checks

net = struct(net);
fcns = nn7.netHints(net,struct);
layerOrder = nn.layer_order(net);
layer2output = cumsum(net.outputConnect);
NID = net.numInputDelays;
NLD = net.numLayerDelays;

Q = nnfast.numsamples(X);
TS = nnfast.numtimesteps(X);
P = cell(net.numInputs,NID+1);
A = cell(net.numLayers,NLD+1);
BZ = cell(net.numLayers,1);
sizeZ = zeros(net.numLayers,1);
Y = cell(net.numOutputs,TS);

A(:,1:NLD) = Ai;

Q1s = ones(1,Q);
for i = layerOrder
  if net.biasConnect(i)
    BZ{i} = net.b{i}(:,Q1s);
  end
  sizeZ(i) = sum([net.biasConnect(i) net.inputConnect(i,:) net.layerConnect(i,:)]);
end

showTime = (TS > 1) || (net.numInputDelays > 1) || (net.numLayerDelays > 1);

for ts = 1:net.numInputDelays
  disp(['Timestep ' num2str(ts-net.numInputDelays)]);
  disp(' ')
  
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = Xi{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      nextpi = processFcn.apply(pi,processFcn.settings);
      d1 = nn_processing_fcn.dy_dx_full(processFcn,pi,nextpi,processFcn.settings,Q);
      d2 = nn_processing_fcn.dy_dx_num(processFcn,pi,nextpi,processFcn.settings);
      d3 = processing_dy_dx_deriv(processFcn.apply,pi,nextpi,processFcn.settings,d1);
      [numericProblems,maxderiv] = print_error(object,processFcn,'dy_dx',d1,d2,d3,numericProblems,maxderiv);
      pi = nextpi;
    end
    P{i,ts} = pi;
  end
  
  disp(' ')
end

for ts = 1:TS
  
  if showTime
    disp(['Timestep ' num2str(ts)]);
    disp(' ')
  end
  
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = X{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      nextpi = processFcn.apply(pi,processFcn.settings);
      d1 = nn_processing_fcn.dy_dx_full(processFcn,pi,nextpi,processFcn.settings,Q);
      d2 = nn_processing_fcn.dy_dx_num(processFcn,pi,nextpi,processFcn.settings);
      d3 = processing_dy_dx_deriv(processFcn.apply,pi,nextpi,processFcn.settings,d1);
      [numericProblems,maxderiv] = print_error(object,processFcn,'dy_dx',d1,d2,d3,numericProblems,maxderiv);
      pi = nextpi;
    end
    P{i,1+NID} = pi;
  end
  if net.numInputs > 0, disp(' '); end
  
  for i=layerOrder

    S = net.layers{i}.size;
        
    Z = cell(1,sizeZ(i));
    zind = 1;

    if net.biasConnect(i)
      Z{zind} = BZ{i};
      zind = zind + 1;
    end

    % Input Weights
    for j=1:net.numInputs
      if net.inputConnect(i,j)
        object = ['inputWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.inputWeights(i,j).weight;
        info = feval(weightFcn.mfunction,'info');
        
        w = net.IW{i,j};
        d = net.inputWeights{i,j}.delays;
        p = cat(1,P{j,NID+1-d});
        z = weightFcn.apply(w,p,weightFcn.param);
        R = net.inputs{j}.processedSize * numel(d);
        
        % discontinuity
        if any(feval([weightFcn.mfunction '.discontinuity'],w,p,weightFcn.param))
          discont{end+1} = [upper(weightFcn.mfunction) ' weight function discontinuity.'];
        end
        
        % dz_dp
        d1 = nn_weight_fcn.dz_dp_full(weightFcn,w,p,z,weightFcn.param);
        d2 = nn_weight_fcn.dz_dp_num(weightFcn,w,p,z,weightFcn.param);
        d3 = weight_fcn_p_deriv(weightFcn.apply,w,p,z,weightFcn.param,d1,info.weightDerivType);
        [numericProblems,maxderiv] = print_error(object,weightFcn,'dz_dp',d1,d2,d3,numericProblems,maxderiv);
        
        % dp - backprop
        dz = rand(S,Q);
        dp1 = weightFcn.backprop(dz,w,p,z,weightFcn.param);
        dp2 = zeros(R,Q);
        for q=1:Q
          dp2(:,q) = d1{q}'*dz(:,q);
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,weightFcn,'backprop',dp1,dp2,analyticProblems,maxderiv);
        
        % dp - forwardprop
        dp = rand(R,Q);
        dz1 = weightFcn.forwardprop(dp,w,p,z,weightFcn.param);
        dz2 = zeros(S,Q);
        for q=1:Q
          dz2(:,q) = d1{q}*dp(:,q);
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,weightFcn,'forwardprop',dz1,dz2,analyticProblems,maxderiv);
      
        % dz_dw
        d1 = nn_weight_fcn.dz_dw_full(weightFcn,w,p,z,weightFcn.param);
        d2 = nn_weight_fcn.dz_dw_num(weightFcn,w,p,z,weightFcn.param);
        d3 = weight_fcn_w_deriv(weightFcn.apply,w,p,z,weightFcn.param,d1,info.weightDerivType);
        [numericProblems,maxderiv] = print_error(object,weightFcn,'dz_dw',d1,d2,d3,numericProblems,maxderiv);
        
        % IGNORE KNOWN PROBLEMS
        % KNOWN PROBLEM: Extremely large W or P
        if (max_abs_element(w) > 1e28) || (max_abs_element(p) > 1e28)
          ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e28.'];
        end
        % KNOWN PROBLEM: DIST and NEGDIST with extremely large W or P
        if any(strcmp(weightFcn.mfunction,{'dist','negdist'}))
          if (max_abs_element(w) > 1e15) || (max_abs_element(p) > 1e15)
            ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e15.'];
          end
        end
        % KNOWN PROBLEM: NORMPROD with extremely small max p
        if strcmp(weightFcn.mfunction,'normprod') && any(any(max(abs(p),[],1) < 1e-6))
          ignore{end+1} = 'NORMPROD maximum input value less than 1e-6.';
        end
        
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    for j=1:net.numLayers
      if net.layerConnect(i,j)
        object = ['layerWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.layerWeights(i,j).weight;
        info = feval(weightFcn.mfunction,'info');
        w = net.LW{i,j};
        d = net.layerWeights{i,j}.delays;
        p = cat(1,A{j,NLD+1-d});
        z = weightFcn.apply(w,p,weightFcn.param);
        R = net.layers{j}.size * numel(d);
        
        % discontinuity
        if any(feval([weightFcn.mfunction '.discontinuity'],w,p,weightFcn.param))
          discont{end+1} = [upper(weightFcn.mfunction) ' weight function discontinuity.'];
        end
        
        d1 = nn_weight_fcn.dz_dp_full(weightFcn,w,p,z,weightFcn.param);
        d2 = nn_weight_fcn.dz_dp_num(weightFcn,w,p,z,weightFcn.param);
        d3 = weight_fcn_p_deriv(weightFcn.apply,w,p,z,weightFcn.param,d1,info.weightDerivType);
        [numericProblems,maxderiv] = print_error(object,weightFcn,'dz_dp',d1,d2,d3,numericProblems,maxderiv);
        
        dz = rand(S,Q);
        dp1 = weightFcn.backprop(dz,w,p,z,weightFcn.param);
        dp2 = zeros(R,Q);
        for q=1:Q
          dp2(:,q) = d1{q}'*dz(:,q);
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,weightFcn,'backprop',dp1,dp2,analyticProblems,maxderiv);
        
        dp = rand(R,Q);
        dz1 = weightFcn.forwardprop(dp,w,p,z,weightFcn.param);
        dz2 = zeros(S,Q);
        for q=1:Q
          dz2(:,q) = d1{q}*dp(:,q);
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,weightFcn,'forwardprop',dz1,dz2,analyticProblems,maxderiv);
        
        d1 = nn_weight_fcn.dz_dw_full(weightFcn,w,p,z,weightFcn.param);
        d2 = nn_weight_fcn.dz_dw_num(weightFcn,w,p,z,weightFcn.param);
        d3 = weight_fcn_w_deriv(weightFcn.apply,w,p,z,weightFcn.param,d1,info.weightDerivType);
        [numericProblems,maxderiv] = print_error(object,weightFcn,'dz_dw',d1,d2,d3,numericProblems,maxderiv);
        
        % IGNORE KNOWN PROBLEMS
        % KNOWN PROBLEM: Extremely large W or P
        if (max_abs_element(w) > 1e28) || (max_abs_element(p) > 1e28)
          ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e28.'];
        end
        % KNOWN PROBLEM: DIST and NEGDIST with extremely large W or P
        if any(strcmp(weightFcn.mfunction,{'dist','negdist'}))
          if (max_abs_element(w) > 1e15) || (max_abs_element(p) > 1e15)
            ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e15.'];
          end
        end
        % KNOWN PROBLEM: NORMPROD with extremely small p
        if strcmp(weightFcn.mfunction,'normprod') && any(any(max(abs(p),[],1) < 1e-6))
          ignore{end+1} = 'NORMPROD maximum input value less than 1e-6.';
        end
        
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    % Net Input Function
    object = ['layers{' num2str(i) '}'];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,net.layers{i}.size,Q,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,Q) + n; end
    for j=1:sizeZ(i)
      d1 = netFcn.dn_dzj(j,Z,n,netFcn.param);
      d2 = nn_net_input_fcn.dn_dzj_num(netFcn,j,Z,n,netFcn.param);
      d3 = net_fcn_derive(netFcn.apply,j,Z,netFcn.param,d1);
      [numericProblems,maxderiv] = print_error(object,netFcn,['dn_dz' num2str(j)],d1,d2,d3,numericProblems,maxderiv);
    end

    % Trasfer Function
    transferFcn = fcns.layers(i).transfer;
    a = transferFcn.apply(n,transferFcn.param);
    d1 = nn_transfer_fcn.da_dn_full(transferFcn,n,a,transferFcn.param);
    d2 = nn_transfer_fcn.da_dn_num(transferFcn,n,a,transferFcn.param);
    d3 = transfer_fcn_derive(transferFcn.apply,n,transferFcn.param,d1);
    [numericProblems,maxderiv] = print_error(object,transferFcn,'da_dn',d1,d2,d3,numericProblems,maxderiv);
    A{i,1+NLD} = a;
    
    % forwardprop
    dn = rand(S,Q,N);
    da1 = transferFcn.forwardprop(dn,n,a,transferFcn.param);
    da2 = zeros(S,Q,N);
    for q=1:Q
      for qq=1:N
        da2(:,q,qq) = d1{q}*dn(:,q,qq);
      end
    end
    [analyticProblems,maxderiv] = print_analytic_error(object,transferFcn,'forwardprop',da1,da2,analyticProblems,maxderiv);

    % backprop
    da = rand(S,Q,N);
    dn1 = transferFcn.backprop(da,n,a,transferFcn.param);
    dn2 = zeros(S,Q,N);
    for q=1:Q
      for qq=1:N
        dn2(:,q,qq) = d1{q}'*da(:,q,qq);
      end
    end
    [analyticProblems,maxderiv] = print_analytic_error(object,transferFcn,'backprop',dn1,dn2,analyticProblems,maxderiv);

    % discontinuity
    if any(feval([transferFcn.mfunction '.discontinuity'],n,transferFcn.param))
      discont{end+1} = [upper(transferFcn.mfunction) ' transfer function discontinuity.'];
    end
    
    % known instabilities
    if strcmp(transferFcn.mfunction,'radbasn')
      if any(any(bsxfun(@minus,-n.*n,max(-n.*n,[],1)) < -700))
        ignore{end+1} = 'RADBASN has too large of a span between net input elements.';
      end
    end
  
    if net.outputConnect(i)
      ii = layer2output(i);
      object = ['outputs{' num2str(ii) '}'];
      yi = A{i,1+NLD};
      for j=length(fcns.outputs(ii).process):-1:1

        % Output Processing Function - Reverse
        processFcn = fcns.outputs(ii).process(j);
        nextyi = processFcn.reverse(yi,processFcn.settings);
        d1 = full_processing_dx_dy(processFcn.dx_dy(nextyi,yi,processFcn.settings),Q);
        d2 = nn_processing_fcn.dx_dy_num(processFcn,nextyi,yi,processFcn.settings);
        d3 = processing_dx_dy_deriv(processFcn.reverse,nextyi,yi,processFcn.settings,d1); %%%% MOVE TO SEPARATE FCN
        [numericProblems,maxderiv] = print_error(object,processFcn,'dx_dy',d1,d2,d3,numericProblems,maxderiv);

        % backprop reverse
        dx = rand(size(nextyi,1),Q,N);
        dy1 = processFcn.backpropReverse(dx,nextyi,yi,processFcn.settings);
        dy2 = zeros(size(yi,1),Q,N);
        for q=1:Q
          for qq=1:N
            dy2(:,q,qq) = d1{q}' * dx(:,q,qq);
          end
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,processFcn,'bp rev',dy1,dy2,analyticProblems,maxderiv);

        % forwardprop reverse
        dy = rand(size(yi,1),Q,N);
        dx1 = processFcn.forwardpropReverse(dy,nextyi,yi,processFcn.settings);
        dx2 = zeros(size(nextyi,1),Q,N);
        for q=1:Q
          for qq=1:N
            dx2(:,q,qq) = d1{q} * dy(:,q,qq);
          end
        end
        [analyticProblems,maxderiv] = print_analytic_error(object,processFcn,'fp rev',dx1,dx2,analyticProblems,maxderiv);

        yi = nextyi;
      end
      Y{ii,ts} = yi;
    end
    disp(' ')
  end
  
  % Shift input states
  P = [P(:,2:end) cell(net.numInputs,1)];
  A = [A(:,2:end) cell(net.numLayers,1)];
  
  if ~isempty(analyticProblems)
    return
  end
  
end % ts

if showTime
  disp('Performance')
  disp(' '),
end

object = 'net';
performFcn = fcns.perform;
d1 = cell(size(T));
d2 = cell(size(T));
d3 = cell(size(T));
E = gsubtract(T,Y);
E = nn_performance_fcn.normalize_error(net,E,performFcn.param);
for i=1:numel(T)
  ti = T{i};
  yi = Y{i};
  ei = E{i};
  %perf = performFcn.apply(ti,yi,ei,performFcn.param);
  d1{i} = performFcn.backprop(ti,yi,ei,performFcn.param);
end
d1 = nn_performance_fcn.normalize_error(net,d1,performFcn.param);
for i=1:numel(T)
  ti = T{i};
  yi = Y{i};
  ei = E{i};
  d2{i} = nn_performance_fcn.dperf_dy_num(performFcn,ti,yi,ei,performFcn.param);
  d3{i} = performance_y_derive(performFcn,ti,yi,ei,performFcn.param,d1{i});
end
[numericProblems,maxderiv] = print_error(object,performFcn,'dperf_dy',d1,d2,d3,numericProblems,maxderiv);

% IGNORE KNOWN PROBLEM: Extremely large error
if any(strcmp(performFcn.mfunction,{'sae','sse'}))
  e = cell2mat(T)-cell2mat(Y);
  if (max(max(abs(e))) > 1e15)
    ignore{end+1} = [upper(performFcn.mfunction) ' error too large for accuracy.'];
  end
end

% === PROCESSING DY_DX DERIVATIVE

function y = processing_y_wrapper(x,f,v,s,i,j)
persistent processingFcn;
persistent X;
persistent settings;
persistent indX;
persistent indY;
if ischar(x) && strcmp(x,'setup');
  processingFcn = f;
  X = v;
  settings = s;
  indX = i;
  indY = j;
  y = @processing_y_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    X2 = X;
    X2(indX) = x(i);
    yall = processingFcn(X2,settings);
    y(i) = yall(indY);
  end
end

function d = processing_dy_dx_deriv(processingFcn,x,y,settings,da)
[numX,Q] = size(x);
[numY,Q] = size(y);
d = cell(1,Q);
for q=1:Q
  xq = x(:,q);
  dq = zeros(numY,numX);
  for indY=1:numY
    for indX=1:numX
      fcn = processing_y_wrapper('setup',processingFcn,xq,settings,indX,indY);
      dq(indY,indX) = nntest.numderivn(fcn,xq(indX),da{q}(indY,indX));
    end
  end
  d{q} = dq;
end

% === WEIGHT dz_dw DERIVATIVE

function y = weight_w_wrapper(x,f,w,wi,inp,s,p)
persistent fcn;
persistent weights;
persistent weightIndex;
persistent neuronIndex;
persistent inputs;
persistent param;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  weights = w;
  weightIndex = wi;
  neuronIndex = s;
  inputs = inp;
  param = p;
  y = @weight_w_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(y)
    weights2 = weights;
    weights2(weightIndex) = x(i);
    yy = fcn(weights2,inputs,param);
    y(i) = yy(neuronIndex);
  end
end

function d = weight_fcn_w_deriv(f,weights,inputs,winputs,param,da,weightDerivType)
[S,Q] = size(winputs);
[R,Q] = size(inputs);
N = numel(weights);
if weightDerivType == 2 % Type 2
  d = zeros(S,N,Q);
  for i=1:S
    for q=1:Q
      for n=1:N
        fcn = weight_w_wrapper('setup',f,weights,n,inputs(:,q),i,param);
        d(i,n,q) = nntest.numderivn(fcn,weights(n),da(i,n,q));
      end
    end
  end
else % Types 0 & 1
  d = cell(1,S);
  for i=1:S
    di = zeros(R,Q);
    for q=1:Q
      for j=1:R
        fcn = weight_w_wrapper('setup',f,weights(i,:),j,inputs(:,q),1,param);
        di(j,q) = nntest.numderivn(fcn,weights(i,j),da{i}(j,q));
      end
    end
    d{i} = di;
  end
end

% === WEIGHT dz_dp DERIVATIVE

function y = weight_p_wrapper(x,f,w,inp,r,s,p)
persistent fcn;
persistent weights;
persistent inputs;
persistent inputIndex;
persistent neuronIndex;
persistent param;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  weights = w;
  inputs = inp;
  inputIndex = r;
  neuronIndex = s;
  param = p;
  y = @weight_p_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(y)
    inputs2 = inputs;
    inputs2(inputIndex) = x(i);
    yy = fcn(weights,inputs2,param);
    y(i) = yy(neuronIndex);
  end
end

function d = weight_fcn_p_deriv(f,weights,inputs,winputs,param,da,weightDerivType)
[S,R1] = size(weights);
[S,Q] = size(winputs);
[R2,Q] = size(inputs);
d = cell(1,Q);
for q=1:Q
  di = zeros(S,R2);
  for s=1:S
    for r=1:R2
      if weightDerivType ~= 2
        ww = weights(s,:);
        ss = 1;
      else
        ww = weights;
        ss = s;
      end
      fcn = weight_p_wrapper('setup',f,ww,inputs(:,q),r,ss,param);
      di(s,r) = nntest.numderivn(fcn,inputs(r,q),da{q}(s,r));
    end
  end
  d{q} = di;
end

% === NET INPUT DERIVATIVE

function y = net_fcn_wrapper(x,f,z,j,p,s,q)
persistent fcn;
persistent allz;
persistent jind;
persistent param;
persistent S;
persistent Q;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  allz = z;
  jind = j;
  param = p;
  y = @net_fcn_wrapper;
  S = s;
  Q = q;
else
  y = zeros(size(x));
  for i=1:numel(x)
    allz2 = allz;
    allz2{jind} = x(i);
    y(i) = fcn(allz2,S,Q,param);
  end
end

function d = net_fcn_derive(tf,j,z,p,da)
[S,Q] = size(z{j});
d = zeros(S,Q);
for i=1:S
  for q=1:Q
    ziq = nnfast.getelements(nnfast.getsamples(z,q),i);
    fcn = net_fcn_wrapper('setup',tf,ziq,j,p,S,Q);
    d(i,q) = nntest.numderivn(fcn,ziq{j},da(i,q));
  end
end

% === TRANSFER FCN DERIVATIVE

function y = transfer_fcn_wrapper(x,f,inp,p,xi,yi)
persistent fcn;
persistent inputs;
persistent param;
persistent xind;
persistent yind;
if ischar(x) && strcmp(x,'setup');
  fcn = f;
  inputs = inp;
  param = p;
  xind = xi;
  yind = yi;
  y = @transfer_fcn_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    inputs2 = inputs;
    inputs2(xind) = x(i);
    yall = fcn(inputs2,param);
    y(i) = yall(yind);
  end
end

function d = transfer_fcn_derive(tf,n,param,da)
[S,Q] = size(n);
d = cell(1,Q); 
for q=1:Q
  dq = zeros(S,S);
  for yind=1:S
    for xind=1:S
      fcn = transfer_fcn_wrapper('setup',tf,n(:,q),param,xind,yind);
      dq(yind,xind) = nntest.numderivn(fcn,n(xind,q),da{q}(yind,xind));
    end
  end
  d{q} = dq;
end

% === PERFORMANCE DPERF_DY DERIVATIVE

function y = performance_y_wrapper(x,f,t,Y,e,p)
persistent fcn;
persistent target;
persistent output;
persistent err;
persistent param;
persistent enorm;
if ischar(x) && strcmp(x,'setup')
  fcn = f;
  target = t;
  output = Y;
  err = e;
  param = p;
  y = @performance_y_wrapper;
  enorm = e ./ (target-output);
else
  e2 = (target-x).*enorm;
  y = fcn(target,x,e2,param);
end

function d = performance_y_derive(f,t,y,e,param,da)
[N,Q] = size(y);
d = zeros(N,Q);
for j=1:N
  for q=1:Q
    fcn = performance_y_wrapper('setup',f.apply,t(j,q),y(j,q),e(j,q),param);
    d(j,q) = nntest.numderivn(fcn,y(j,q),da(j,q));
  end
end

% === PERFORMANCE WB DERIVATIVE

function y = performance_wb_wrapper(x,f,n,y,t,ew,p,i)
persistent fcn;
persistent net;
persistent wb;
persistent outputs;
persistent targets;
persistent errorWeights;
persistent param;
persistent index;
if ischar(x) && strcmp(x,'setup')
  fcn = f;
  net = n;
  wb = getwb(net);
  outputs = y;
  targets = t;
  errorWeights = ew;
  param = p;
  index = i;
  y = @performance_wb_wrapper;
else
  wb2 = wb;
  wb2(index) = x;
  net2 = setwb(net,wb2);
  y = fcn.performance_wb(net2,param);
end

% === PROCESSING DX_DY DERIVATIVE

function d2 = full_processing_dx_dy(d1,Q)
if iscell(d1)
  d2 = d1;
else
  d2 = cell(1,Q);
  d2(:) = {d1};
end

function y = processing_x_wrapper(x,f,v,s,i,j)
persistent processingFcn;
persistent vector;
persistent settings;
persistent inputIndex;
persistent outputIndex;
if ischar(x) && strcmp(x,'setup');
  processingFcn = f;
  vector = v;
  settings = s;
  inputIndex = i;
  outputIndex = j;
  y = @processing_x_wrapper;
else
  y = zeros(size(x));
  for i=1:numel(x)
    vector2 = vector;
    vector2(outputIndex) = x(i);
    yall = processingFcn(vector2,settings);
    y(i) = yall(inputIndex);
  end
end

function d = processing_dx_dy_deriv(processingFcn,x,y,settings,da)
[N,Q] = size(x);
[M,Q] = size(y);
d = cell(1,Q); 
for q=1:Q
  yq = y(:,q);
  dq = zeros(N,M);
  for i=1:N
    for j=1:M
      fcn = processing_x_wrapper('setup',processingFcn,yq,settings,i,j);
      dq(i,j) = nntest.numderivn(fcn,yq(j),da{q}(i,j));
    end
  end
  d{q} = dq;
end

% ====

function [problems,maxderiv] = print_error(object,fcn,derivName,d1,d2,d3,problems,maxderiv)

absTolerance = 1e-10;
relTolerance = 1e-7;

if iscell(d1)
  d1 = cell2mat(d1);
  d2 = cell2mat(d2);
  d3 = cell2mat(d3);
end
mag = sqrt(sumsqr(d1));
if isempty(mag), mag = 0; end
if mag == 0
  scale = 1;
else
  scale = mag;
end
e1 = sqrt(sumsqr(d1-d2))/scale;
e2 = sqrt(sumsqr(d1-d3))/scale;

failed = (e2 > relTolerance) && (scale*e2 > absTolerance);
if failed
  probstr = '  <<< FAILED NUMERIC';
  problems{end+1} = ['Failed derivative: ' upper(fcn.mfunction) ', ' derivName];
else
  maxderiv = max(maxderiv,mag);
  probstr = '';
end

object = [object nnstring.spaces(20-length(object))];
fcnName = fcn.mfunction;
derivName = [fcnName nnstring.spaces(27-length(fcnName)-length(derivName)) derivName];
magStr = sprintf('%g',mag);
magStr = [magStr nnstring.spaces(12-length(magStr))];
e1str = sprintf('%g',e1);
e1str = [e1str nnstring.spaces(12-length(e1str))];
fprintf('%s%s  mag: %s num5: %s numN: %g%s\n',...
  object,derivName,magStr,e1str,e2,probstr);

if failed
  %keyboard
end

function [problems,maxderiv] = print_analytic_error(object,fcn,derivName,d1,d3,problems,maxderiv)

absTolerance = 1e-10;
relTolerance = 1e-7;

if iscell(d1)
  d1 = cell2mat(d1);
  d3 = cell2mat(d3);
end
mag = sqrt(sumsqr(d1));
if isempty(mag), mag = 0; end
if mag == 0
  scale = 1;
else
  scale = mag;
end
e_abs = sqrt(sumsqr(d1-d3));
e_rel = e_abs/scale;
failed = (e_rel > relTolerance) && (e_abs > absTolerance);
if failed
  probstr = '  <<< FAILED ANALYTIC';
  problems = [problems {['Failed derivative: ' upper(fcn.mfunction) '.' derivName]}];
else
  maxderiv = max(maxderiv,mag);
  probstr = '';
end
object = [object nnstring.spaces(20-length(object))];
fcnName = fcn.mfunction;
derivName = [fcnName nnstring.spaces(26-length(fcnName)-length(derivName)) ' ' derivName];
magStr = sprintf('%g',mag);
magStr = [magStr nnstring.spaces(12-length(magStr))];
fprintf('%s%s  mag: %s diff: %g%s\n',...
  object,derivName,magStr,e_rel,probstr);

if failed
 keyboard
end

function x = max_abs_element(x)
if isempty(x)
  x = 0;
else
  while(numel(x) > 1)
    x = max(abs(x));
  end
end

    
