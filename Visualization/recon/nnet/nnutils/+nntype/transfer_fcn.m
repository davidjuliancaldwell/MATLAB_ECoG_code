function [out1,out2] = transfer_fcn(in1,in2,in3)
%NN_TRANSFER_FCN Transfer function type.

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
  info = nnfcnFunctionType(mfilename,'Transfer Function',7,...
    7,fullfile('nnet','nntransfer'));
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
  if isempty(nnpath.fcn2file(fcn))
    err = [FCN ' is not a function on the MATLAB path.'];
    return;
  end
  
  % ---------- FCN.NAME
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn '.name']))
    err = ['Package function +' FCN '/name does not exist.'];
    return
  end
  
  % Name must be a string
  err = nntype.string('check',feval([fcn '.name']));
  if ~isempty(err), err = nnerr.value(err,'VALUE.name'); return; end
    
  % ---------- FCN.PARAMETER_INFO
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn '.parameterInfo']))
    err = ['Package function +' FCN '.parameterInfo does not exist.'];
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
  
  % ---------- FCN(...)
  
  % A must be same size as N
  S = 4;
  Q = 5;
  n1 = rs.rand(S,Q);
  a1 = feval(fcn,n1,defaultParam);
  if (ndims(a1) ~= ndims(n1)) || (any(size(a1) ~= size(n1)))
    err = [FCN ' does not return outputs of same size as inputs.'];
    return
  end
  
  % Permuting columns of N should premute same columns of A
  [~,permutation] = sort(rs.rand(1,Q));
  a2 = feval(fcn,n1(:,permutation),defaultParam);
  if any(any(a2 ~= a1(:,permutation)))
    err = [FCN ' does not return same outputs when samples are permuted.'];
    return
  end
  
  % Calling with default parameters should return same value
  a2 = feval(fcn,n1,defaultParam);
  if (ndims(a2) ~= ndims(a1)) || (any(size(a2) ~= size(a1))) || any(any(a1 ~= a2))
    err = [FCN 'returns different values when parameters are supplied.'];
    return
  end
    
  % Input columns with NaN elements should result in NaN in same element
  % Input columns with no NaN elements should not contain any NaN elements
  n = rs.rand(4,100);
  n(rs.rand(4,100)>0.9) = NaN;
  a = feval(fcn,n,defaultParam);
  nan_n = isnan(n);
  nan_a = isnan(a);
  if any(any(nan_n & ~nan_a))
    err = [FCN ' returns a non-NaN value in same position as a NaN input.'];
    return
  elseif any(~any(nan_n) & any(nan_a))
    err = [FCN ' returns a NaN in a column without any NaN input elements.'];
    return
  end
    
  % ---------- FCN.APPLY
 
  % Apply package function must exist
  if isempty(nnpath.fcn2file([fcn '.apply']))
    err = ['Package function +' FCN '/apply does not exist.'];
    return
  end

  % Calling APPLY package function should return same value
  n1 = rs.rand(4,6);
  a1 = feval(fcn,n1,defaultParam);
  a2 = feval([fcn '.apply'],n1,defaultParam);
  if (ndims(a2) ~= ndims(a1)) || (any(size(a2) ~= size(a1))) || any(any(a1 ~= a2))
    err = [FCN '.apply returns different values from ' FCN '.'];
    return;
  end

  % ---------- FCN.DA_DN - DERIVATIVES
  
  % DA_DN package function must exist
  if isempty(nnpath.fcn2file([fcn '.da_dn']))
    err = ['Package function +' FCN '/da_dn does not exist.'];
    return
  end

  % FCN.da_dn must return 1xQ cell of SxS double, or  dimensions
  S = 4;
  Q = 5;
  n = rs.rand(S,Q);
  a = feval(fcn,n,defaultParam);
  d = feval([fcn '.da_dn'],n,a,defaultParam);
  if iscell(d)
    if (ndims(d) > 2) || any(size(d) ~= [1 Q])
      err = [FCN '.da_dn returns cell array of incorrect dimensions.'];
      return;
    end
    for q=1:Q
      dq = d{q};
      if ~isa(dq,'double')
        err = [FCN '.da_dn returns cell array with non-double elements.'];
        return;
      end
      if (ndims(dq) > 2) || any(size(dq) ~= [S S])
        err = [FCN '.da_dn returns cell array of incorrect dimensions.'];
        return;
      end
    end
  elseif isa(d,'double')
    if (ndims(d) > 2) || any(size(d) ~= [S Q])
      err = [FCN '.da_dn returns a double array of incorrect dimensions.'];
      return;
    end
  else
    err = [FCN '.da_dn returns a value which is not a cell array or double.'];
  end
  
  % Numeric derivative check
  da_dn1 = cell2mat(nn_transfer_fcn.da_dn_full(fcn,n,a,defaultParam));
  da_dn2 = cell2mat(nn_transfer_fcn.da_dn_num(fcn,n,a,defaultParam));
  rel_diff = max(max(abs(da_dn1-da_dn2)))/sqrt(sum(sum(da_dn1 .^ 2)));
  if rel_diff > 1e-9
    err = [FCN '.da_dn returns incorrect derivative values.'];
    return
  end
  
  % ---------- FCN.BACKPROP
  
  % Backprop package function must exist
  if isempty(nnpath.fcn2file([fcn '.backprop']))
    err = ['Package function +' fcn '/backprop does not exist.'];
    return
  end
  
  % Backpropagation must be consistent with derivatives
  N = 7;
  da = rs.rand(S,Q,N);
  da_dn = nn_transfer_fcn.da_dn_full(fcn,n,a,defaultParam);
  dn1 = zeros(S,Q,N);
  for q=1:Q
    for qq=1:N
      dn1(:,q,qq) = da_dn{q}'*da(:,q,qq);
    end
  end
  dn2 = feval([fcn '.backprop'],da,n,a,defaultParam);
  diff = max(abs(dn1(:)-dn2(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.da_dn.'];
    return
  end

  % ---------- FCN.FORWARDPROP
  
  % Forwardprop package function must exist
  if isempty(nnpath.fcn2file([fcn '.forwardprop']))
    err = ['Package function +' fcn '/forwardprop does not exist.'];
    return
  end
  
  % Forward propagation must be consistent with derivatives
  dn = rs.rand(S,Q,N);
  da_dn = nn_transfer_fcn.da_dn_full(fcn,n,a,defaultParam);
  da1 = zeros(S,Q,N);
  for q=1:Q
    for qq=1:N
      da1(:,q,qq) = da_dn{q}*dn(:,q,qq);
    end
  end
  da2 = feval([fcn '.forwardprop'],dn,n,a,defaultParam);
  diff = max(abs(da1(:)-da2(:)));
  if (diff > 1e-9)
    err = [FCN '.forwardprop returns values not consistent with ' FCN '.da_dn.'];
    return
  end
  
  % ---------- FCN() ==> INFO
  
  info = feval(fcn,'info');
  if ~isstruct(info)
    err = [FCN '() does not return an NN_TRANSFER_FCN.INFO structure.'];
    return
  end
  
  % ---------- INFO.MFILENAME
  
  if ~strcmp(fcn,info.mfunction)
    err = [FCN ' returns info.mfunction not equal to ''' fcn '.'];
    return
  end
  
  % ---------- NNET 7.0 Backward Compatibility
  
  nnet7_fcns = {'compet','hardlim','hardlims','logsig','netinv','poslin','purelin',...
    'radbas','radbasn','satlin','satlins','softmax','tansig','tribas'};
  if ~isempty(nnstring.match(fcn,nnet7_fcns)), return; end
  
  % FCN('apply',...) should equal FCN(...)
  n = rs.rand(4,6);
  a1 = feval(fcn,n,defaultParam);
  a2 = feval(fcn,'apply',n,defaultParam);
  if (ndims(a1)~=ndims(a2)) || any(size(a1) ~= size(a2)) || any(any(a1 ~= a2))
    err = [FCN '(''apply'',...) does not return same values as ' FCN '.apply(...).'];
    return
  end
  
  % FCN('da_dn',...) should equal FCN.da_dn(...)
  d1 = feval([fcn '.da_dn'],n,a1,defaultParam);
  d2 = feval(fcn,'da_dn',n,a1,defaultParam);
  if (iscell(d1) ~= iscell(d2))
    err = [FCN '(''da_dn'',...) does not return same values as ' FCN '.da_dn(...).'];
    return
  end
  if iscell(d1), d1 = cell2mat(d1); d2 = cell2mat(d2); end
  if (ndims(d1)~=ndims(d2)) || any(size(d1) ~= size(d2)) || any(any(d1 ~= d2))
    err = [FCN '(''da_dn'',...) does not return same values as ' FCN '.da_dn(...).'];
    return
  end
  
  % ---------- NNET 6.0 Backward Compatibility
  
  % FCN('dn',...) should equal FCN.da_dn(...)
  d1 = feval([fcn '.da_dn'],n,a1,defaultParam);
  d2 = feval(fcn,'dn',n,a1,defaultParam);
  if (iscell(d1) ~= iscell(d2))
    err = [FCN '(''da_dn'',...) does not return same values as ' FCN '.da_dn(...).'];
    return
  end
  if iscell(d1), d1 = cell2mat(d1); d2 = cell2mat(d2); end
  if (ndims(d1)~=ndims(d2)) || any(size(d1) ~= size(d2)) || any(any(d1 ~= d2))
    err = [FCN '(''da_dn'',...) does not return same values as ' FCN '.da_dn(...).'];
    return
  end
end

function fcn = strict_format(fcn)
  fcn = nntype.modular_fcn('format',fcn);
end
