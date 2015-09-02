function [out1,out2] = msne(varargin)
%MSNE Mean squared normalized error performance function.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    perf = msne(E,Y,X,FP)
%    dPerf_dy = msne('dy',E,Y,net,perf,FP);
%    dPerf_dx = msne('dx',E,Y,net,perf,FP);
%    info = msne(code)
%
%  Description
%
%    MSNE is a network performance function.  It measures the
%    network's performance according to the mean of squared normalized
%    errors. Normalized errors are calculated as the difference between
%    targets and outputs after they are each normalized to [-1,1].
%
%    The normalization insures that networks with multiple outputs will
%    be trained so that accuracy of each outputs is treated as equally
%    important. Without normalization outputs with larger values
%    (and therefore larger errors) would be treated as more important.
%  
%    MSNE(E,Y,X,PP) takes E and optional function parameters,
%      E   - Matrix or cell array of error vectors.
%      Y   - Matrix or cell array of output vectors. (ignored).
%      NET - Neural network.
%      FP  - Function parameters (ignored).
%     and returns the mean squared error.
%
%    MSNE('dy',E,Y,NET,PERF,FP) returns derivative of PERF with respect to Y.
%    MSNE('dx',E,Y,NET,PERF,FP) returns derivative of PERF with respect to X.
%
%    MSNE('name') returns the name of this function.
%    MSNE('pnames') returns the name of this function.
%    MSNE('pdefaults') returns the default function parameters.
%  
%  Examples
%
%    Here a two layer feed-forward network is created with a 1-element
%    input ranging from -10 to 10, targets ranging from 0 to 1, and four
%    hidden  neurons, using MSNE as its performance function.
%
%      net = newff([-10 0 10],[0 0.5 1],4);
%      net.performFcn = 'msne';
%
%    Here the network is given a batch of inputs P.  The error
%    is calculated by subtracting the output A from target T.
%    Then the mean squared error is calculated.
%
%      p = [-10 -5 0 5 10];
%      t = [0 0 1 1 1];
%      y = net(p)
%      e = t-y
%      perf = msne(e,y,net)
%
%  Network Use
%
%    To prepare a custom network to be trained with MSNE set
%    NET.performFcn to 'msne'.  This will automatically set
%    NET.performParam to the empty matrix [], as MSNE has no
%    performance parameters.
%
%    In either case, calling TRAIN or ADAPT will result
%    in MSNE being used to calculate performance.
%
%  See also MSE, MSEREG, MSNEREG, MAE

% Copyright 1992-2011 The MathWorks, Inc.
% $Revision: 1.1.8.7 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Performance Functions.

  persistent INFO;
  if isempty(INFO),INFO = get_info; end
  if nargin < 1,error(message('nnet:Args:NotEnough')); end
  in1 = varargin{1};
  if ischar(in1)
    switch lower(in1)
      
      % User Functionality
      
      case 'apply'
        % this('apply',net,t,y,*ew,...*param...)
        % Same as calling: this(net,t,y,*ew,...*param...)
        % Calculate performance
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 3, error(message('nnet:Args:NotEnough')); end
        [net,err] = nntype.network_or_struct('format',args{1},'NET');
        if ~isempty(err), nnerr.throw(err); end
        [t,err] = nntype.data('format',args{2},'targets T');
        if ~isempty(err), nnerr.throw(err); end
        [y,err] = nntype.data('format',args{3},'Output data Y');
        if ~isempty(err), nnerr.throw(err); end
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if nargs < 4
          ew = {1};
        else
          [ew,err] = nntype.nndata_pos('format',varargin{4},'Error weights EW');
          if ~isempty(err), nnerr.throw(err); end
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        out1 = apply(net,t,y,ew,param);
      
      case 'dperf_dy',
        % this('dperf_dy',net,t,y,*ew,*perf,...*param...)
        % Derivative of performance with respect to network outputs
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        if (nargs < 5)
          perf = apply(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_dy(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'dperf_dwb',
        % this('dperf_dwb',net,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        nnassert.minargs(nargs,1);
        net = nntype.network('format',args{1},'NET');
        out1 = dperf_dwb(net,param);
        
      % Implementation
      
      case 'e'
        % this('e',net,t,y,*ew,...*param...)
        % Errors taking into account error weights and normalization
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3},args{4});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        out1 = adjusted_errors(net,t,y,ew,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'perf_y'
        % this('perf_y',net,t,y,*ew,...*param...)
        % Performance due to network outputs
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{1},args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        [out1,out2] = performance_y(net,t,y,ew,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'perf_wb'
        % this('perf_y',net,...param...)
        % Performance due to weights and biases
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 1), nnerr.throw('Not enough input arguments.'); end
        net = nntype.network('format',args{1},'NET');
        [out1,out2] = performance_wb(net,param);
        
      case 'dperf_de',
        % this('dperf_de',net,t,y,*ew,*perf,...*param...)
        % Derivative of performance with respect to errors
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe,Me] = nnsize(ew);
          if ((Me~= 1) && (Me ~= numel(Ny))) || ((Me~=1) && any((Ne ~= Ny) & (Ne ~= 1)))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        if (nargs < 5)
          perf = apply(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_de(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
      
      % Testing
      
      case 'dperf_dy_num',
        % this('dperf_dy',net,t,y,*ew,*perf,...*param...)
        % Derivative of perfor
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        if (nargs < 5)
          perf = performance(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_dy_num(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
      
      case 'dperf_de_num',
        % this('dperf_de',net,t,y,ew,perf,...param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nnerr.throw('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          error(message('nnet:NNData:TandYDontMatch'));
        end
        if (nargs < 4)
          ew = {1};
        else
          [ew,err] = nntype.nndata_pos('format',args{4},'Error weights EW');
          if ~isempty(err),nnerr.throw(err); end
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
            error(message('nnet:NNData:EWandYDontMatch'));
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            error(message('nnet:NNData:EWandYDontMatch'));
          end
        end
        if (nargs < 5)
          perf = performance(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_de_num(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'combine'
        % this('combine',net,x1,n1,x2,n2,param)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 5
          error(message('nnet:Args:NotEnough'));
        end
        [net,err] = nntype.network('format',args{1});
        if ~isempty(err), nnerr.throw(nnerr.value(err,'NET')); end
        [x1,n1,x2,n2] = deal(args(2:end));
        out1 = combine_perf_y_or_grad(net,x1,n1,x2,n2,param);
        
      case 'weight'
        % this('weight',net,x1,n1,nTotal,param)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 4
          error(message('nnet:Args:NotEnough'));
        end
        [net,err] = nntype.network('format',args{1});
        if ~isempty(err), nnerr.throw(nnerr.value(err,'NET')); end
        [x1,n1,nTotal] = deal(args(2:end));
        out1 = weight_perf_y_or_grad(net,x1,n1,nTotal,param);
        
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'check_param'
        % this('check_param',param)
        out1 = check_param(varargin{2});
        
      % NNET 6.0 Compatibility
      
      case 'dy'
        % this('dy',e,y,x,perf,pp)
        if nargin < 6, param = INFO.defaultParam; else param = varargin{6}; end
        if isempty(param), param = INFO.defaultParam; end
        e = varargin{2};
        y = varargin{3};
        perf = varargin{5};
        wasMatrix = ~iscell(e);
        if wasMatrix, e = {e}; y = {y}; end
        t = gadd(e,y);
        out1 = gnegate(dperf_dy([],t,y,{1},perf,param));
        if (wasMatrix), out1 = out1{1}; end
        
      case 'dx'
        % this('dx',e,y,x,perf,param)
        if nargin < 6, param = INFO.defaultParam; else param = varargin{6}; end
        if isempty(param), param = INFO.defaultParam; end
        x = varargin{4};
        out1 = dperf_dwb(x,param);
        
      % Implementation
      
      % Info field access
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' in1]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  end
 
  % NNET 4.0 and 6.0 Compatibility
      
  in1 = varargin{1};
  if ~(isa(in1,'network') || isstruct(in1))
    e = in1;
    if ~iscell(e), e = {e}; end
    if isstruct(varargin{end}) || isa(varargin{end},'nnetParam')
      param = varargin{end};
      varargin(end) = [];
    else
      param = INFO.defaultParam;
    end
    if length(varargin) < 3, wb = 0; else wb = varargin{3}; end
    if length(varargin) == 1
      t = e;
      y = {0};
    elseif ~iscell(varargin{2}) && (size(varargin{2},2)==1)
      t = e;
      y = {0};
      wb = varargin{2};
    else
      y = varargin{2};
      t = gadd(e,y);
    end
    out1 = apply(wb,t,y,{1},param);
    return
  end
  
  % User Functionality
  
  % this(net,t,y,ew,...*param...)
  % Same as calling: this('apply',net,t,y,ew,...*param...)
  % Calculate performance
  [args,param,nargs] = nnparam.extract_param(varargin,INFO.defaultParam);
  if nargs < 3, error(message('nnet:Args:NotEnough')); end
  [net,err] = nntype.network_or_struct('format',args{1},'NET');
  if ~isempty(err), nnerr.throw(err); end
  [t,err] = nntype.data('format',args{2},'targets T');
  if ~isempty(err), nnerr.throw(err); end
  [y,err] = nntype.data('format',args{3},'Output data Y');
  if ~isempty(err), nnerr.throw(err); end
  [Nt,Qt,TSt] = nnsize(t);
  [Ny,Qy,TSy] = nnsize(y);
  if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
    error(message('nnet:NNData:TandYDontMatch'));
  end
  if nargs < 4
    ew = {1};
  else
    [ew,err] = nntype.nndata_pos('format',args{4},'Error weights EW');
    if ~isempty(err), nnerr.throw(err); end
    [Ne,Qe,TSe] = nnsize(ew);
    if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) & (Ne ~= 1))) || (numel(Ne) ~= 1)
      error(message('nnet:NNData:EWandYDontMatch'));
    end
    if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
      error(message('nnet:NNData:EWandYDontMatch'));
    end
  end
  out1 = apply(net,t,y,ew,param);
end

function perf = apply(net,t,y,ew,param)
  perfy = performance_y(net,t,y,ew,param);
  perfwb = performance_wb(net,param);
  perf = perfy + perfwb;
end

function d = dperf_dy_num(net,t,y,ew,perf,param)
  delta = 1e-7;
  [N,Q,TS,M] = nnsize(y);
  d = nndata(N,Q,TS,0);
  y2 = y;
  for ts=1:TS
    for q=1:Q
      for i=1:M
        for j=1:N(i)
          y2{i,ts}(j,q) = y{i,ts}(j,q) + 2*delta;
          perf1 = performance_y(net,t,y2,ew,param);
          y2{i,ts}(j,q) = y{i,ts}(j,q) + delta;
          perf2 = performance_y(net,t,y2,ew,param);
          y2{i,ts}(j,q) = y{i,ts}(j,q) - delta;
          perf3 = performance_y(net,t,y2,ew,param);
          y2{i,ts}(j,q) = y{i,ts}(j,q) - 2*delta;
          perf4 = performance_y(net,t,y2,ew,param);
          d{i,ts}(j,q) = (-perf1 + 8*perf2 - 8*perf3 + perf4) ./ (12*delta);
        end
      end
    end
  end
end

function d = dperf_de(net,t,y,ew,perf,param)
  d = gnegate(dperf_dy(net,t,y,ew,perf,param));
end

function d = dperf_de_num(net,t,y,ew,perf,param)
  d = gnegate(dperf_de_num(net,t,y,ew,perf,param));
end

function d = dperf_dwb_num(wb,param)
  delta = 1e-7;
  if ~isnumeric(wb), wb = getwb(wb); end
  numVar = length(wb);
  d = zeros(numVar,1);
  for i=1:numVar
    perf1 = performance_wb(addwb(wb,i,2*delta),param);
    perf2 = performance_wb(addwb(wb,i,+delta),param);
    perf3 = performance_wb(addwb(wb,i,-delta),param);
    perf4 = performance_wb(addwb(wb,i,-2*delta),param);
    d(i) = -(-perf1 + 8*perf2 - 8*perf3 + perf4) / (12*delta);
  end
end

function wb = addwb(wb,i,v)
  wb(i) = wb(i) + v;
end

function sf = subfunctions
  sf.apply = @apply;
  sf.adjust_error = @adjust_error;
  sf.performance_y = @performance_y;
  sf.performance_wb = @performance_wb;
  sf.combine_perf_y_or_grad = @combine_perf_y_or_grad;
  sf.weight_perf_y_or_grad = @weight_perf_y_or_grad;
  sf.dperf_dae = @dperf_dae;
  sf.dperf_dy = @dperf_dy;
  sf.dperf_de = @dperf_de;
  sf.dperf_dwb = @dperf_dwb;
  sf.dperf_dy_num = @dperf_dy_num;
  sf.dperf_de_num = @dperf_de_num;
  sf.dperf_dwb_num = @dperf_dwb_num;
end

function info = get_info
  info = nnfcnPerformance(mfilename,function_name,7,subfunctions,...
    parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Mean Squared Normalized Error'; end
function param = parameters, param = []; end

function err = check_param(param)
  err = '';
end

function e = adjust_error(net,e,ew,param)
  e = nnperf.norm_err(net,e);
  e = gmultiply(e,gsqrt(ew));
end

function [perfy,n] = performance_y(net,t,y,ew,param)
  e = gsubtract(t,y);
  e = adjust_error(net,e,ew,param);
  [perfy,n] = meansqr(e);
end

function [perfwb,n] = performance_wb(net,param)
  perfwb = 0; n = 1;
end

function [x,n] = combine_perf_y_or_grad(x1,n1,x2,n2,param)
  n = n1 + n2;
  x = ((x1*n1) + (x2*n2)) ./ n;
end

function d = dperf_dy(net,t,y,ew,perf,param)
  e = gsubtract(t,y);
  e = adjust_error(net,e,ew,param);
  d = cell(size(e));
  n = 0;
  for i=1:numel(e)
    di = e{i};
    dontcares = find(~isfinite(di));
    di(dontcares) = 0;
    d{i} = di;
    n = n + numel(di) - length(dontcares);
  end
  m = (-2/n);
  for i=1:numel(d)
    d{i} = m * d{i};
  end
  d = adjust_error(net,d,ew,param);
end

function d = dperf_dwb(wb,param)
  if isnumeric(wb)
    d = zeros(size(wb));
  else
    d = zeros(wb.numWeightElements,1);
  end
end

function d = dperf_dae(net,e,param)
  d = cell(size(e));
  n = 0;
  for i=1:numel(e)
    di = e{i};
    dontcares = find(~isfinite(di));
    di(dontcares) = 0;
    d{i} = di;
    n = n + numel(di) - length(dontcares);
  end
  m = -(2/n);
  for i=1:numel(d)
    d{i} = m * d{i};
  end
end
