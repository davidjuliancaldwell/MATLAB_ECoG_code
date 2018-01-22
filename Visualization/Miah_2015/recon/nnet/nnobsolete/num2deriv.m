function out1 = num2deriv(in1,in2,in3,in4,in5,in6,in7)
%NUM2DERIV Numeric two-point network derivative function.
%
%  <a href="matlab:doc num2deriv">num2deriv</a>('dperf_dwb',net,X,T,Xi,Ai,EW) takes a network, inputs X,
%  targets T, initial input states Xi, initial layer states Ai, and error
%  weights EW, and returns the gradient, the derivative of performance with
%  respect to the network's weights and biases.
%
%  <a href="matlab: doc num2deriv">numderiv</a>('de_dwb',net,X,T,Xi,Ai,EW) returns the Jacobian, the
%  derivative of each error with respect to the network's weights and biases.
%
%  <a href="matlab: doc num2deriv">staticderiv</a> calculates derivatives numerically and is therefore
%  much slower than the other derivative functions.  Its purpose is for
%  checking the calculations of the other derivative functions, and the
%  partial derivatives calculated by the network's input processing, weight,
%  net input, transfer, output processing and performance functions.
%
%  Here a feedforward network is trained and derivatives calculated.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(20);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y = net(x);
%    perf = <a href="matlab:doc perform">perform</a>(net,t,y)
%    dwb = <a href="matlab:doc num2deriv">num2deriv</a>('dperf_dwb',net,x,t)
%
%  See also DEFAULTDERIV, BTTDERIV, FPDERIV, NUM5DERIV.

% Copyright 2010-2012 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Propagation Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'dperf_dwb'
        if nargin < 4, error(message('nnet:Args:NotEnough')); end
        if nargin < 5, in5 = {}; end
        if nargin < 6, in6 = {}; end
        if nargin < 7, in7 = {1}; end
        [net,err] = nntype.network('format',in2,'Network');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [x,err] = nntype.data('format',in3,'Input data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [t,err] = nntype.data('format',in4,'Target data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [xi,err] = nntype.data('format',in5,'Input states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ai,err] = nntype.data('format',in6,'Layer states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ew,err] = nntype.data('format',in7,'Error weights');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [out1,err] = dperf_dwb(net,x,t,xi,ai,ew);
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        
      case 'de_dwb'
        if nargin < 4, error(message('nnet:Args:NotEnough')); end
        if nargin < 5, in5 = {}; end
        if nargin < 6, in6 = {}; end
        if nargin < 7, in7 = {1}; end
        [net,err] = nntype.network('format',in2,'Network');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [x,err] = nntype.data('format',in3,'Input data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [t,err] = nntype.data('format',in4,'Target data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [xi,err] = nntype.data('format',in5,'Input states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ai,err] = nntype.data('format',in6,'Layer states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ew,err] = nntype.data('format',in7,'Error weights');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [out1,err] = de_dwb(net,x,t,xi,ai,ew);
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        
      case 'gradient'
        if nargin < 4, in4 = nn.subfcns(in2); end
        out1 = calc_gradient(in2,in3,in4);
      case 'jacobian'
        if nargin < 4, in4 = nn.subfcns(in2); end
        out1 = calc_jacobian(in2,in3,in4);
        
      % Testing
      
      case 'dperf_dwb_jac'
        if nargin < 4, error(message('nnet:Args:NotEnough')); end
        if nargin < 5, in5 = {}; end
        if nargin < 6, in6 = {}; end
        if nargin < 7, in7 = {1}; end
        [net,err] = nntype.network('format',in2,'Network');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [x,err] = nntype.data('format',in3,'Input data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [t,err] = nntype.data('format',in4,'Target data');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [xi,err] = nntype.data('format',in5,'Input states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ai,err] = nntype.data('format',in6,'Layer states');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [ew,err] = nntype.data('format',in7,'Error weights');
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        [out1,err] = dperf_dwb_jac(net,x,t,xi,ai,ew);
        if ~isempty(err), throwAsCaller(MException(nnerr.tag('Arguments',2),err)); end
        
      % NNET 6 Compatibility
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, 
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  end
end

function [dwb,err] = dperf_dwb(net,x,t,xi,ai,ew)
  [x,xi,ai,t,Q,TS,err] = nnsim.prep(net,x,xi,ai,t);
  if ~isempty(err), dwb=[]; return; end
  if (Q == 0) || (TS == 0)
    dwb = feval(net.performFcn,'dperf_dwb',net,net.performParam);
    return
  end
  fcns = nn7.netHints(net);
  [data.Pc,t] = nntraining.fix_nan_inputs(net,x,xi,ai,t,Q,TS);
  if net.efficiency.cacheDelayedInputs && (net.numInputDelays > 0);
    data.Pd = nn7.pd(net,data.Pc,Q,TS,fcns);
    data.Pc = [];
  else
    data.Pd = [];
  end
  data.Ai = ai;
  data.T = t;
  data.EW = ew;
  data.Q = Q;
  data.TS = TS;
  fcns = nn7.dataHints(net,data,fcns);
  [~,data] = nn7.perf_all(net,data,fcns);
  dwb = calc_gradient(net,data,fcns);
  reg = net.performParam.regularization;
  if (reg > 0)
    dwb = (1-reg)*dwb + reg*feval(net.performFcn,'dperf_dwb',net,net.performParam);
  end
end

function [dperf_dwb,err] = dperf_dwb_jac(net,x,t,xi,ai,ew)
  [dae_dwb,err] = de_dwb(net,x,t,xi,ai,ew);
  if ~isempty(err), dperf_dwb =[]; return, end
  y = nncalc.y(net,x,xi,ai);
  e = gsubtract(t,y);
  sf = feval(net.performFcn,'subfunctions');
  ae = nn_performance_fcn.adjust_error(net,e,ew,net.performParam);
  dperf_dae = sf.dperf_dae(net,ae,net.performParam);
  dperf_dae = cell2mat(dperf_dae);
  dperf_dae = dperf_dae(:);
  dperf_dwb = dae_dwb * dperf_dae;
end

function [dwb,err] = de_dwb(net,x,t,xi,ai,ew)
  [x,xi,ai,t,Q,TS,err] = nnsim.prep(net,x,xi,ai,t);
  if ~isempty(err), dwb=[]; return; end
  if (Q == 0) || (TS == 0)
    dwb = zeros(net.numWeightElements,0);
    return
  end
  fcns = nn7.netHints(net);
  [data.Pc,t] = nntraining.fix_nan_inputs(net,x,xi,ai,t,Q,TS);
  if net.efficiency.cacheDelayedInputs && (net.numInputDelays > 0);
    data.Pd = nn7.pd(net,data.Pc,Q,TS,fcns);
    data.Pc = [];
  else
    data.Pd = [];
  end
  data.Ai = ai;
  data.T = t;
  data.EW = ew;
  data.Q = Q;
  data.TS = TS;
  fcns = nn7.dataHints(net,data,fcns);
  [~,data] = nn7.perf_all(net,data,fcns);
  dwb = calc_jacobian(net,data,fcns);
  reg = net.performParam.regularization;
  if (reg > 0)
    dwb = (1-reg)*dwb + reg*feval(net.performFcn,'dperf_dwb',net,net.performParam);
  end
end
  
function sf = subfunctions
  sf.calc_gradient = @calc_gradient;
  sf.calc_jacobian = @calc_jacobian;
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnDerivative(mfilename,'Numerical 2-Point',...
    fcnversion,subfunctions);
end

function gWB = calc_gradient(net,data,fcns)
  gWB = zeros(net.numWeightElements,1);
  if any([data.Q data.TS net.numOutputs net.numWeightElements] == 0)
    gWB = zeros(net.numWeightElements,1);
    return
  end
  delta = 1e-7;
  perf1 = data.perf;
  WB = getwb(net);
  WB2 = WB;
    
  for i=1:length(WB)
    WB2(i) = WB(i) + delta;
    net2 = setwb(net,WB2);
    perf2 = nn7.perf_only(net2,data,fcns);
    gWB(i) = (perf1-perf2)/delta;
    WB2(i) = WB(i);
  end
end

function jWB = calc_jacobian(net,data,fcns)
  numOutputs = nn.output_sizes(net);
  jWB = zeros(net.numWeightElements,sum(numOutputs)*data.Q);
  delta = 1e-7;
  WB = getwb(net);
  WB2 = WB;
  e1 = gsubtract(data.T,data.Y);
  e1 = remove_dont_care_errors(e1);
  e1 = nn_performance_fcn.adjust_error(net,e1,data.EW,fcns.perform.param);
  e1 = cell2mat(e1);
  for i=1:net.numWeightElements
    WB2(i) = WB(i)+delta;
    net2 = setwb(net,WB2);
    y2 = nn7.y(net2,data,fcns);
    e2 = gsubtract(data.T,y2);
    e2 = remove_dont_care_errors(e2);
    e2 = nn_performance_fcn.adjust_error(net,e2,data.EW,fcns.perform.param);
    e2 = cell2mat(e2);
    jwb = -(e1-e2)/delta;
    jWB(i,:) = jwb(:)';
    WB2(i) = WB(i);
  end
end

%% Imlementation

function E = remove_dont_care_errors(E)
  for i=1:numel(E)
    ei = E{i};
    ei(isnan(E{i})) = 0;
    E{i} = ei;
  end
end
