function [out1,out2] = weight_fcn(in1,in2,in3)
%NN_WEIGHT_FCN Weight function type.

% Copyright 2010-2012 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Type Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin < 1, error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch (in1)
      
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'isa'
        % this('isa',value)
        out1 = isempty(type_check(in2));
        
      case {'check','assert','test'}
        % [*err] = this('check',value,*name)
        nnassert.minargs(nargin,2);
        if nargout == 0
          err = type_check(in2);
        else
          try
            err = type_check(in2);
          catch me
            out1 = me.message;
            return;
          end
        end
        if isempty(err)
          if nargout>0,out1=''; end
          return;
        end
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout==0, err = nnerr.value(err,'Value'); end
        if nargout > 0
          out1 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'format'
        % [x,*err] = this('format',x,*name)
        err = type_check(in2);
        if isempty(err)
          out1 = strict_format(in2);
          if nargout>1, out2=''; end
          return
        end
        out1 = in2;
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout < 2, err = nnerr.value(err,'Value'); end
        if nargout>1
          out2 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    error(message('nnet:Args:Unrec1'))
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnFunctionType(mfilename,'Weight Function',7,...
    7,fullfile('nnet','nnweight'));
end

function err = type_check(fcn)
  
  % Reproducable Random Stream
  rs = RandStream('mt19937ar','seed',1);
  
  % ---------- FCN
  
  % Function name is a string
  err = nntype.string('check',fcn);
  if ~isempty(err), return; end
  FCN = upper(fcn);
  
  % On path
  if isempty(nnpath.fcn2file(fcn));
    err = [FCN ' is not a function on the MATLAB path.'];
    return;
  end
  
  % ---------- FCN.NAME
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.name']))
    err = ['Package function +' FCN '/name does not exist.'];
    return
  end
  
  % Name must be a string
  err = nntype.string('check',feval([fcn '.name']));
  if ~isempty(err), err = nnerr.value(err,'VALUE.name'); return; end
  
  % ---------- FCN.inputDerivType
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.inputDerivType']))
    err = ['Package function +' FCN '/inputDerivType does not exist.'];
    return
  end
  
  % Check value is 0 or 1
  idt = feval([fcn '.inputDerivType']);
  if ~isnumeric(idt) || ~isscalar(idt)
    err = ['Package function +' FCN '/inputDerivType does not exist.'];
    return
  end
  if (idt ~= 0) && (idt ~= 1)
    err = ['Package function +' FCN '/inputDerivType does return 0 or 1.'];
    return
  end
  
  % ---------- FCN.weightDerivType
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.weightDerivType']))
    err = ['Package function +' FCN '/weightDerivType does not exist.'];
    return
  end
  
  % Check value is 0 or 1
  wdt = feval([fcn '.weightDerivType']);
  if ~isnumeric(wdt) || ~isscalar(wdt)
    err = ['Package function +' FCN '/weightDerivType does not exist.'];
    return
  end
  if (wdt ~= 0) && (wdt ~= 1) && (wdt ~= 2)
    err = ['Package function +' FCN '/weightDerivType does return 0 or 1.'];
    return
  end
  
  % ---------- FCN.PARAMETER_INFO
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.parameterInfo']))
    err = ['Package function +' FCN '/parameterInfo does not exist.'];
    return
  end
  
  % Must return array of parameter info
  param_info = feval([fcn '.parameterInfo']);
  for i=1:length(param_info)
    pi = param_info(i);
    if ~isa(pi,'nnetParamInfo')
      err = ['Package function +' FCN '/parameterInfo does not return array of nnetParamInfo.'];
      return
    end
  end
  defaultParam = nn_modular_fcn.parameter_defaults(fcn);
  
  % ---------- FCN.size
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.size']))
    err = ['Package function +' FCN '/size does not exist.'];
    return
  end

  % Wsize must be 1x2 double positive integer
  R = 8;
  S = 5;
  if strcmp(fcn,'scalprod'), S = R; end
  Wsize = feval([fcn '.size'],S,R,defaultParam);
  
  % ---------- FCN(...)

  % Must return same number of columns
  Q = 12;
  p = rs.rand(R,Q);
  w = rs.rand(Wsize);
  z = feval(fcn,w,p,defaultParam);
  if ~isa(z,'double') || (ndims(z) ~= 2)
    err = [FCN ' does not return two dimensional double value.'];
    return
  end
  if size(z,2) ~= size(z,2)
    err = [FCN ' returns values with different numbers of columns from inputs.'];
    return
  end

  % Supplying no param should return same as supplying default param
  z2 = feval(fcn,w,p,defaultParam);
  if ~isa(z2,'double') || (ndims(z2) ~= 2)
    err = [FCN ' does not return two dimensional double value.'];
    return
  end
  if (ndims(z)~=ndims(z2)) || any(z(:)~=z2(:))
    err = [FCN ' does not return same values for default parameters and no parameters.'];
    return
  end
  if max(max(abs(z-z2))) > 1e-10
    err = [FCN ' does not return same values for default parameters and no parameters.'];
    return
  end
  
  % ---------- FCN.dz_dp - DERIVATIVES
  
  % dz_dp package function must exist
  if isempty(nnpath.fcn2file([fcn,'.dz_dp']))
    err = ['Package function +' FCN '/dz_dp does not exist.'];
    return
  end
  
  % dz_dp must be correct size and type
  dz_dp = feval([fcn '.dz_dp'],w,p,z,defaultParam);
  switch idt
    case 0
      if ~isa(dz_dp,'double') || (ndims(dz_dp)~=2) || any(size(dz_dp)~=[S R])
        err = [FCN '.dz_dp does not return an SxR double array.'];
        return
      end
      if any(isnan(dz_dp(:)))
        err = [FCN '.dz_dp returns NaN values.'];
        return
      end
    case 1
      if ~iscell(dz_dp) || (ndims(dz_dp)~=2) || any(size(dz_dp)~=[1 Q])
        err = [FCN '.dz_dp does not return a 1xQ cell array.'];
        return
      end
      for i=1:S
        di = dz_dp{i};
        if ~isa(di,'double') || (ndims(di)~=2) || any(size(di)~=[S R])
          err = [FCN '.dz_dp does not return a cell array of SxR double arrays.'];
          return
        end
        if any(isnan(di(:)))
          err = [FCN '.dz_dp returns NaN values.'];
          return
        end
      end
  end
  
  % Must be consistent with numerical derivatives
  dz_dp1 = nn_weight_fcn.dz_dp_full(fcn,w,p,z,defaultParam);
  dz_dp2 = nn_weight_fcn.dz_dp_num(fcn,w,p,z,defaultParam);
  diff = max(max(abs(cell2mat(dz_dp1)-cell2mat(dz_dp2))));
  if (diff > 1e-8)
    err = [FCN '.dz_dp is not consistent with numerical derivative.'];
    return
  end
  
  % ---------- FCN.dz_dw - DERIVATIVES
  
  % dz_dw package function must exist
  if isempty(nnpath.fcn2file([fcn,'.dz_dw']))
    err = ['Package function +' FCN '/dz_dw does not exist.'];
    return
  end
  
  % dz_dw must be correct size and type
  dz_dw = feval([fcn '.dz_dw'],w,p,z,defaultParam);
  switch wdt
    case 0
      if ~isa(dz_dw,'double') || (ndims(dz_dw)~=2) || any(size(dz_dw)~=[R Q])
        err = [FCN '.dz_dw does not return an RxQ double array.'];
        return
      end
      if any(isnan(dz_dw(:)))
        err = [FCN '.dz_dw returns NaN values.'];
        return
      end
    case 1
      if ~iscell(dz_dw) || (ndims(dz_dw)~=2) || any(size(dz_dw)~=[1 S])
        err = [FCN '.dz_dw does not return a 1xS cell array.'];
        return
      end
      for i=1:S
        di = dz_dw{i};
        if ~isa(di,'double') || (ndims(di)~=2) || any(size(di)~=[R Q])
          err = [FCN '.dz_dw does not return a cell array of SxR double arrays.'];
          return
        end
        if any(isnan(di(:)))
          err = [FCN '.dz_dw returns NaN values.'];
          return
        end
      end
    case 2
      Nw = numel(w);
      if ~isa(dz_dw,'double') || (ndims(dz_dw)>3)
        err = [FCN '.dz_dw does not return an SxNxQ double array.'];
        return
      end
      if (size(dz_dw,1)~=S) || (size(dz_dw,2)~=Nw) || (size(dz_dw,3)~=Q)
        err = [FCN '.dz_dw does not return an Sxnumel(W)xQ double array.'];
        return
      end
      if any(isnan(dz_dw(:)))
        err = [FCN '.dz_dw returns NaN values.'];
        return
      end
  end
  
  % Must be consistent with numerical derivatives
  dz_dw1 = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
  dz_dw2 = nn_weight_fcn.dz_dw_num(fcn,w,p,z,defaultParam);
  if iscell(dz_dw1), dz_dw1 = cell2mat(dz_dw1); end
  if iscell(dz_dw2), dz_dw2 = cell2mat(dz_dw2); end
  diff = max(max(abs(dz_dw1-dz_dw2)));
  if (diff > 1e-6)
    err = [FCN '.dz_dw is not consistent with numerical derivative.'];
    return
  end
  
  % ---------- FCN.backprop
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backprop']))
    err = ['Package function +' fcn '/backprop does not exist.'];
    return
  end
  
  % Must return correct type and dimensions
  N = 7;
  dz = rs.rand(S,Q,N);
  dp1 = feval([fcn '.backprop'],dz,w,p,z,defaultParam);
  if ~isa(dp1,'double') || (ndims(dp1)>3)
    err = [FCN '.backprop does not return an RxQxN double array.'];
    return
  end
  if any([size(dp1,1) size(dp1,2) size(dp1,3)] ~= [R Q N])
    err = [FCN '.backprop does not return an RxQxN double array.'];
    return
  end
  if any(isnan(dp1(:)))
  err = [FCN '.backprop returns NaN values.'];
    return
  end
  
  % Backpropagation must be consistent with derivatives
  dz_dp = nn_weight_fcn.dz_dp_full(fcn,w,p,z,defaultParam);
  dp2 = zeros(R,Q,N);
  for q=1:Q
    for qq=1:N
      dp2(:,q,qq) = dz_dp{q}'*dz(:,q,qq);
    end
  end
  dp2 = feval([fcn '.backprop'],dz,w,p,z,defaultParam);
  diff = max(abs(dp2(:)-dp1(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dz_dp.'];
    return
  end

  % ---------- FCN.forwardprop
  
  % Forwardprop package function must exist
  if isempty(nnpath.fcn2file([fcn,'.forwardprop']))
    err = ['Package function +' fcn '/forwardprop does not exist.'];
    return
  end
  
  % Must return correct type and dimensions
  dp = rs.rand(R,Q,N);
  dz1 = feval([fcn '.forwardprop'],dp,w,p,z,defaultParam);
  if ~isa(dz1,'double') || (ndims(dz1)>3)
    err = [FCN '.forwardprop does not return an SxQxN double array.'];
    return
  end
  if any([size(dz1,1) size(dz1,2) size(dz1,3)] ~= [S Q N])
    err = [FCN '.forwardprop does not return an SxQxN double array.'];
    return
  end
  if any(isnan(dz1(:)))
  err = [FCN '.forwardprop returns NaN values.'];
    return
  end
  
  % Forward propagation must be consistent with derivatives
  dz_dp = nn_weight_fcn.dz_dp_full(fcn,w,p,z,defaultParam);
  dz2 = zeros(S,Q,N);
  for q=1:Q
    for qq=1:N
      dz2(:,q,qq) = dz_dp{q}*dp(:,q,qq);
    end
  end
  diff = max(abs(dz1(:)-dz2(:)));
  if (diff > 1e-9)
    err = [FCN '.forwardprop returns values not consistent with ' FCN '.dz_dp.'];
    return
  end
  
  % ---------- FCN.backstop
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backstop']))
    err = ['Package function +' fcn '/backstop does not exist.'];
    return
  end
  
  % Must return correct type and dimensions
  dz = rs.rand(S,Q);
  dw1 = feval([fcn '.backstop'],dz,w,p,z,defaultParam);
  if ~isa(dw1,'double')
    err = [FCN '.backstop does not return a double array.'];
    return
  end
  if (ndims(dw1)>2) || any(size(dw1) ~= size(w))
    err = [FCN '.backstop does not an array the same size as W.'];
    return
  end
  if any(isnan(dw1(:)))
  err = [FCN '.backstop returns NaN values.'];
    return
  end
  
  % Backstop must be consistent with derivatives
  switch wdt
    case {0,1}
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
      dw2 = zeros(size(w));
      for i=1:S
        dw2(i,:) = dz(i,:) * dz_dw{i}';
      end
    case 2
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
      dw2 = sum(sum(bsxfun(@times,dz_dw,reshape(dz,S,1,Q)),3),1)';
  end
  diff = max(abs(dw1(:)-dw2(:)));
  if (diff > 1e-9)
    err = [FCN '.backstop returns values not consistent with ' FCN '.dz_dw.'];
    return
  end
  
  % ---------- FCN.backstopParallel
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backstopParallel']))
    err = ['Package function +' fcn '/backstop does not exist.'];
    return
  end
  
  % Must return correct type and dimensions
  N = 7;
  dz = rs.rand(S,Q,N);
  dw1 = feval([fcn '.backstopParallel'],dz,w,p,z,defaultParam);
  if ~isa(dw1,'double')
    err = [FCN '.backstopParallel does not return a double array.'];
    return
  end
  if (ndims(dw1)>4) || any(size(dw1) ~= [size(w) Q N])
    err = [FCN '.backstopParallel does not an array of size(W)xQxN.'];
    return
  end
  if any(isnan(dw1(:)))
  err = [FCN '.backstopParallel returns NaN values.'];
    return
  end
  
  % Backstop parallel must be consistent with derivatives
  switch wdt
    case {0,1}
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
      dw2 = zeros(S,R,Q,N);
      for i=1:S
        dw2(i,:,:,:) = reshape(bsxfun(@times,dz_dw{i},dz(i,:,:)),1,R,Q,N);
      end
    case 2
      M = numel(w);
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
      dw2 = reshape(sum(bsxfun(@times,dz_dw,reshape(dz,S,1,Q,N)),1),M,1,Q,N);
  end
  diff = max(abs(dw1(:)-dw2(:)));
  if (diff > 1e-9)
    err = [FCN '.backstopParallel returns values not consistent with ' FCN '.dz_dw.'];
    return
  end
  
  % ---------- FCN.forwardstart
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.forwardstart']))
    err = ['Package function +' fcn '/forwardstart does not exist.'];
    return
  end
  
  % Must return correct type and dimensions
  dz1 = feval([fcn '.forwardstart'],w,p,z,defaultParam);
  if ~isa(dz1,'double')
    err = [FCN '.forwardstart does not return a double array.'];
    return
  end
  if (ndims(dz1)>4) || any([size(dz1,1) size(dz1,2) size(dz1,3) size(dz1,4)] ~= [S Q size(w)])
    err = [FCN '.forwardstart does not an array of Sxsize(W).'];
    return
  end
  if any(isnan(dz1(:)))
    err = [FCN '.forwardstart returns NaN values.'];
    return
  end
  
  % Forwardstart must be consistent with derivatives
  switch wdt
    case {0,1}
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam); % {S}(RxQ)
      dz2 = zeros(S,Q,S,R);
      for i=1:S
        dz2(i,:,i,:) = reshape(dz_dw{i}',1,Q,1,R);
      end
    case 2
      dz_dw = nn_weight_fcn.dz_dw_full(fcn,w,p,z,defaultParam);
      dz2 = permute(dz_dw,[1 3 2]);
  end
  diff = max(abs(dz1(:)-dz2(:)));
  if (diff > 1e-9)
    err = [FCN '.forwardstart returns values not consistent with ' FCN '.dz_dp.'];
    return
  end
  
  %
end

function x = strict_format(x)
  x = lower(x);
end

