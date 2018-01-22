function out1 = performance_fcn(fcn,varargin)

% Copyright 2012 The MathWorks, Inc.

info = nnModuleInfo(fcn);
in1 = varargin{1};
if ischar(in1)
  switch (in1)

    % NNET 7.0 Compatibility

    case 'apply'
      [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
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

      e = gsubtract(t,y);
      switch param.normalization
        case 'none', % no change required
        case 'standard', e = nnperf.norm_err(net,e);
        case 'percent', e = nnperf.perc_err(net,e);
      end
      ew = info.perfe_to_ew(ew);
      e = gmultiply(e,gsqrt(ew));
      perf = info.apply(t,y,ee,param);
      if info.normalize
        perf = perf / numfinite(e);
      end
      reg = net.performParam.regularization;
      if (reg ~= 0)
        wb = getwb(net);
        perfwb = info.apply(zeros(size(wb)),wb,-wb,param);
        if info.normalize, perfwb = perfwb / numel(wb); end
        perf = perf * (reg-1) + perfwb * reg;
      end
      out1 = perf;
 
    case 'dperf_dwb',
      [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
      nnassert.minargs(nargs,1);
      net = nntype.network('format',args{1},'NET');
      out1 = info.dperf_dwb(getwb(net),param);

    case {'info','subfunctions'}
      out1 = info;
      
    case {'pdefaults','defaultParam'}
      out1 = info.defaultParam;
      
    case 'parameters'
      out1 = info.parameterInfo;
      
    case 'name'
      out1 = info.name;
      
    case 'pnames'
      out1 = fieldnames(info.defaultParam);

    % NNET 6.0 Compatibility

    case 'dy'
      if nargin < 6, param = info.defaultParam; else param = varargin{6}; end
      if isempty(param), param = info.defaultParam; end
      e = varargin{2};
      y = varargin{3};
      %perf = varargin{5};
      wasMatrix = ~iscell(e);
      if wasMatrix, e = {e}; y = {y}; end
      t = gadd(e,y);
      net.performFcn = info.mfunction;
      out1 = nncalc.dperform(net,t,y,{1},param);
      if (wasMatrix), out1 = out1{1}; end

    case 'dx'
      if nargin < 6, param = info.defaultParam; else param = varargin{6}; end
      if isempty(param), param = info.defaultParam; end
      wb = varargin{4};
      if isstruct(wb) || isa(wb,'network')
        wb = getwb(wb);
      end
      out1 = info.dperf_dwb(wb,param);
  end
else
  
  % NNET 4.0 and 6.0 Compatibility
  
  e = in1;
  if iscell(e), e = cell2mat(e); end
  perfs = info.apply([],[],e);
  dontcare = find(isnan(perfs));
  perfs(dontcare) = 0;
  perf = sum(sum(perfs));
  if info.normalize
    perf = perf / (numel(perfs)-numel(dontcare));
  end
  out1 = perf;
end
  
  
