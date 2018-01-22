function [out1,out2] = net_input_fcn(in1,in2,in3)
%NN_NET_INPUT_FCN Net input function type.

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
  info = nnfcnFunctionType(mfilename,'Net Input Function',7,...
    7,fullfile('nnet','nnnetinput'));
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
  if isempty(nnpath.fcn2file([fcn,'.name']))
    err = ['Package function +' fcn '/name does not exist.'];
    return
  end
  
  % Name must be a string
  err = nntype.string('check',feval([fcn '.name']));
  if ~isempty(err), err = nnerr.value(err,'VALUE.name'); return; end
    
  % ---------- FCN.PARAMETER_INFO
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.parameterInfo']))
    err = ['Package function +' fcn '/parameterInfo does not exist.'];
    return
  end
  
  % Must return array of parameter info
  param_info = feval([fcn '.parameterInfo']);
  for i=1:length(param_info)
    pi = param_info(i);
    if ~isa(pi,'nnetParamInfo')
      err = ['Package function +' fcn '/parameterInfo does not return array of nnetParamInfo.'];
      return
    end
  end
  defaultParam = nn_modular_fcn.parameter_defaults(fcn);
  
  % ---------- FCN(...)
  
  % Result dimensions must match input argument dimensions
  S = 3;
  Q = 20;
  z1 = rs.rand(S,Q);
  z2 = rs.rand(S,Q);
  z3 = rs.rand(S,Q);
  zz = {z1 z2 z3};
  n = feval(fcn,zz,S,Q,defaultParam);
  if (ndims(n) ~= 2) || any(size(n) ~= [S Q])
    err = [FCN ' returns net input with different dimensions from weighted inputs.'];
    return;
  end
  
  % Results should be the same regardless of argument order
  n2 = feval(fcn,zz,S,Q,defaultParam);
  if (ndims(n2)~=ndims(n)) || (any(size(n2)~=size(n))) || (max(abs(n2(:) - n(:)))>1e-10)
    err = [FCN ' returns different results when arguments are reordered.'];
    return;
  end
  
  % NaN values should flow through in element-wise manner
  nan_pos = rand(size(z1))>0.5;
  num_pos = ~nan_pos;
  z1_nan = zeros(size(z1));
  z1_nan(nan_pos) = NaN;
  z1_nan(num_pos) = z1(num_pos);
  n = feval(fcn,{z1_nan z2 z3},S,Q,defaultParam);
  if any(isnan(n(num_pos))) || any(~isnan(n(nan_pos)))
    err = [FCN ' does not propagate NaN values in element-wise fassion.'];
    return;
  end
  
  % ---------- FCN.APPLY
  
  % Apply package function must exist
  if isempty(nnpath.fcn2file([fcn,'.apply']))
    err = ['Package function +' fcn '/apply does not exist.'];
    return
  end

  % Calling APPLY package function should return same value
  S = 3;
  Q = 20;
  z1 = rs.rand(S,Q);
  z2 = rs.rand(S,Q);
  z3 = rs.rand(S,Q);
  zz = {z1 z2 z3};
  n1 = feval(fcn,zz,S,Q,defaultParam);
  n2 = feval([fcn '.apply'],zz,S,Q,defaultParam);
  if (ndims(n2) ~= ndims(n1)) || (any(size(n2) ~= size(n1))) || any(any(n2 ~= n1))
    err = [FCN '.apply returns different values from ' FCN '.'];
    return;
  end
  
  % ---------- FCN.DN_DZJ - Derivatives
  
  % DN_DZJ package function must exist
  if isempty(nnpath.fcn2file([fcn,'.dn_dzj']))
    err = ['Package function +' FCN '/dn_dzj does not exist.'];
    return
  end

  % Check derivative dimensions
  dz1 = feval([fcn,'.dn_dzj'],1,zz,n,defaultParam);
  if (ndims(dz1) ~= 2) || any(size(dz1) ~= [S Q])
    err = [upper(fcn) ' returns derivative with different dimensions from weighted inputs.'];
    return;
  end
  dz2 = feval([fcn,'.dn_dzj'],2,zz,n,defaultParam);
  if (ndims(dz2) ~= 2) || any(size(dz2) ~= [S Q])
    err = [upper(fcn) ' returns derivative with different dimensions from weighted inputs.'];
    return;
  end
  dz3 = feval([fcn,'.dn_dzj'],3,zz,n,defaultParam);
  if (ndims(dz3) ~= 2) || any(size(dz3) ~= [S Q])
    err = [upper(fcn) ' returns derivative with different dimensions from weighted inputs.'];
    return;
  end
  
  % ---------- FCN.BACKPROP
  
  % Backprop package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backprop']))
    err = ['Package function +' fcn '/backprop does not exist.'];
    return
  end
  
  % Backpropagation must be consistent with derivatives
  N = 7;
  dn = rs.rand(S,Q,N);
  dza = bsxfun(@times,dn,dz1);
  dzb = feval([fcn '.backprop'],dn,1,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  dza = bsxfun(@times,dn,dz2);
  dzb = feval([fcn '.backprop'],dn,2,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  dza = bsxfun(@times,dn,dz3);
  dzb = feval([fcn '.backprop'],dn,3,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  
  % ---------- FCN.FORWARDPROP
  
  % Forwardprop package function must exist
  if isempty(nnpath.fcn2file([fcn,'.forwardprop']))
    err = ['Package function +' fcn '/forwardprop does not exist.'];
    return
  end
  
  % Backpropagation must be consistent with derivatives
  N = 7;
  dz = rs.rand(S,Q,N);
  dza = bsxfun(@times,dz,dz1);
  dzb = feval([fcn '.forwardprop'],dz,1,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  dza = bsxfun(@times,dz,dz2);
  dzb = feval([fcn '.forwardprop'],dz,2,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  dza = bsxfun(@times,dz,dz3);
  dzb = feval([fcn '.forwardprop'],dz,3,zz,n,defaultParam);
  diff = max(abs(dza(:)-dzb(:)));
  if (diff > 1e-9)
    err = [FCN '.backrop returns values not consistent with ' FCN '.dn_dzj.'];
    return
  end
  
  % ---------- NNET 7.0 Backward Compatibility
  
  nnet7_fcns = {'netsum','netprod'};
  if ~isempty(nnstring.match(fcn,nnet7_fcns)), return; end
  
  % FCN('apply',...) should equal FCN(...)
  S = 3;
  Q = 20;
  z1 = rs.rand(S,Q);
  z2 = rs.rand(S,Q);
  z3 = rs.rand(S,Q);
  zz = {z1 z2 z3};
  n1 = feval(fcn,zz,S,Q,defaultParam);
  n2 = feval(fcn,'apply',zz,S,Q,defaultParam);
  if (ndims(n1)~=ndims(n2)) || any(size(n1) ~= size(n2)) || any(any(n1 ~= n2))
    err = [FCN '(''apply'',...) does not return same values as ' FCN '.apply(...).'];
    return
  end
  
  % FCN('dn_dzj',...) should equal FCN.dn_dzj(...)
  dz1 = feval([fcn,'.dn_dzj'],1,zz,n1,defaultParam);
  dz2 = feval(fcn,'dn_dzj',1,zz,n1,defaultParam);
  if (ndims(dz1) ~= ndims(dz2)) || any(dz1(:) ~= dz2(:))
    err = [FCN '(''dn_dzj'',...) does not return same values as ' FCN '.dn_dzj(...).'];
    return
  end
  
  % ---------- NNET 6.0 Backward Compatibility
  
  % FCN('dz',...) should equal FCN.dn_dzj(...)
  dz1 = feval([fcn,'.dn_dzj'],1,zz,n1,defaultParam);
  dz2 = feval(fcn,'dz',1,zz,n1,defaultParam);
  if (ndims(dz1) ~= ndims(dz2)) || any(dz1(:) ~= dz2(:))
    err = [FCN '(''dz'',...) does not return same values as ' FCN '.dn_dzj(...).'];
    return
  end
  
end

function x = strict_format(x)
  x = lower(x);
end

