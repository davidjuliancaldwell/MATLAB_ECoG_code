function [out1,out2] = processing_fcn(in1,in2,in3)
%NN_PROCESSING_FCN Processing function type.

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
  info = nnfcnFunctionType(mfilename,'Processing Function',7,...
    7,fullfile('nnet','nnprocess'));
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
    err = ['Package function +' FCN '/name does not exist.'];
    return
  end
  
  % Name must be a string
  err = nntype.string('check',feval([fcn '.name']));
  if ~isempty(err), err = nnerr.value(err,'VALUE.name'); return; end
    
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
  
  % ---------- FCN.PROCESS_INPUTS
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.processInputs']))
    err = ['Package function +' FCN '/processInputs does not exist.'];
    return
  end

  % Must be logical scalar
  pi = feval([fcn '.processInputs']);
  if ~isscalar(pi) || ~islogical(pi)
    err = [FCN '.processInputs does not return a scalar logical value.'];
    return
  end
  
  % ---------- FCN.PROCESS_OUTPUTS
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.processOutputs']))
    err = ['Package function +' FCN '/processOutputs does not exist.'];
    return
  end

  % Must be logical scalar
  po = feval([fcn '.processOutputs']);
  if ~isscalar(po) || ~islogical(po)
    err = [FCN '.processOutputs does not return a scalar logical value.'];
    return
  end

  % ---------- FCN(...)

  % Must return same number of columns
  Xsize = 5;
  Q = 12;
  x = rs.rand(Xsize,Q);
  [y,settings] = feval(fcn,x,defaultParam);
  Ysize = size(y,1);
  if ~isa(y,'double') || (ndims(y) ~= 2)
    err = [FCN ' does not return two dimensional double value.'];
    return
  end
  if size(y,2) ~= size(x,2)
    err = [FCN ' returns processed values with different numbers of columns from inputs.'];
    return
  end

  % Supplying no param should return same as supplying default param
  [y2,settings2] = feval(fcn,x);
  if ~isa(y,'double') || (ndims(y2) ~= 2)
    err = [FCN ' does not return two dimensional double value.'];
    return
  end
  if (ndims(y)~=ndims(y2)) || any(y(:)~=y2(:))
    err = [FCN ' does not return same values for default parameters and no parameters.'];
    return
  end
  if any(y(:)~=y2(:))
    err = [FCN ' does not return same values for default parameters and no parameters.'];
    return
  end
  
  % Name/value Param should return same as default param
  names = fieldnames(defaultParam);
  pairs = cell(1,numel(names)*2);
  for i=1:numel(names)
    pairs{(i-1)*2+1} = names{i};
    pairs{(i-1)*2+2} = defaultParam.(names{i});
  end
  [y2,settings3] = feval(fcn,x,pairs{:});
  if ~isa(y2,'double') || (ndims(y2) ~= 2)
    err = [FCN ' does not return two dimensional double value.'];
    return
  end
  if (ndims(y)~=ndims(y2)) || any(y(:)~=y2(:))
    err = [FCN ' does not return same values for default parameters and no parameters.'];
    return
  end
  if any(y(:)~=y2(:))
    err = [FCN ' does not return same values for parameter structure vs. name/value pairs.'];
    return
  end
  
  % ---------- FCN.CREATE(...)

  % Create package function must exist
  if isempty(nnpath.fcn2file([fcn,'.create']))
    err = ['Package function +' FCN '/create does not exist.'];
    return
  end

  % Calling CREATE package function should return same value
  [y2,settings2] = feval([fcn '.create'],x,defaultParam);
  if ~isa(y2,'double') || (ndims(y2) ~= 2)
    err = [FCN '.create does not return two dimensional double value.'];
    return
  end
  if (ndims(y)~=ndims(y2)) || any(y(:)~=y2(:))
    err = [FCN '.create returns different values from ' FCN '.'];
    return
  end

  % ---------- FCN.APPLY(...)

  % Apply package function must exist
  if isempty(nnpath.fcn2file([fcn,'.apply']))
    err = ['Package function +' FCN '/apply does not exist.'];
    return
  end

  % Calling APPLY package function should return same value
  y2 = feval([fcn '.apply'],x,settings);
  if ~isa(y2,'double') || (ndims(y2) ~= 2)
    err = [FCN '.create does not return two dimensional double value.'];
    return
  end
  if (ndims(y2) ~= ndims(y)) || (any(size(y2) ~= size(y))) || any(any(y2 ~= y))
    err = [FCN '.apply returns different values from ' FCN '.'];
    return;
  end

  % ---------- FCN.REVERSE(...)

  % Reverse package function must exist
  if isempty(nnpath.fcn2file([fcn,'.reverse']))
    err = ['Package function +' FCN '/reverse does not exist.'];
    return
  end

  % Calling APPLY package function should return same value
  x2 = feval([fcn '.reverse'],y,settings);
  if ~isa(x2,'double') || (ndims(x2) ~= 2)
    err = [FCN '.reverse does not return two dimensional double value.'];
    return
  end
  if (ndims(x2) ~= ndims(x)) || (any(size(x2) ~= size(x))) || any(abs(x2(:)-x(:))>1e-12)
    err = [FCN '.reverse is not consistent with ' FCN '.apply.'];
    return;
  end


  % ---------- FCN.DY_DX - DERIVATIVES
  
  % DY_DX package function must exist
  if isempty(nnpath.fcn2file([fcn,'.dy_dx']))
    err = ['Package function +' FCN '/dy_dx does not exist.'];
    return
  end
  
  % DY_DX must be correct size and type
  dy_dx = feval([fcn '.dy_dx'],x,y,settings);
  if ~iscell(dy_dx) || (size(dy_dx,1)~=1)
    err = [FCN '.dy_dx does not return a row cell array.'];
    return
  end
  if size(dy_dx,2) ~= size(x,2)
    err = [FCN '.dy_dx does not return cell array with same number of columns as input arguments.'];
    return
  end
  for i=1:size(x,2)
    di = dy_dx{i};
    if ~isa(di,'double') || (ndims(di) ~= 2)
      err = [FCN '.dy_dx does not return a row cell array of double values.'];
      return
    end
    if any(size(di) ~= [size(x,1) size(y,1)])
      err = [FCN '.dy_dx contains elements which are not size(x,1) by size(y,1).'];
      return
    end
  end

  % ---------- FCN.DX_DY - DERIVATIVES
  
  % DX_DY package function must exist
  if isempty(nnpath.fcn2file([fcn,'.dx_dy']))
    err = ['Package function +' FCN '/dx_dy does not exist.'];
    return
  end

  % DX_DY must be correct size and type
  dx_dy = feval([fcn '.dx_dy'],x,y,settings);
  if ~iscell(dx_dy) || (size(dx_dy,1)~=1)
    err = [FCN '.dx_dy does not return a row cell array.'];
    return
  end
  if size(dx_dy,2) ~= size(x,2)
    err = [FCN '.dx_dy does not return cell array with same number of columns as input arguments.'];
    return
  end
  for i=1:size(x,2)
    di = dx_dy{i};
    if ~isa(di,'double') || (ndims(di) ~= 2)
      err = [FCN '.dx_dy does not return a row cell array of double values.'];
      return
    end
    if any(size(di) ~= [size(x,1) size(y,1)])
      err = [FCN '.dx_dy contains elements which are not size(x,1) by size(y,1).'];
      return
    end
  end
  
  % DX_DY must be inverse of DX_DY
  for q=1:Q
    d1 = dy_dx{q};
    d2 = dx_dy{q};
    if max(max(abs(d2-pinv(d1)))) > 1e-9
      err = [FCN '.dy_dx and ' FCN '.dx_dy return values that are inconsistent.'];
      return
    end
  end
  
  % ---------- FCN.BACKPROP
  
  % BACKPROP package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backprop']))
    err = ['Package function +' FCN '/backprop does not exist.'];
    return
  end
  
  % BACKPROP must be consistent with DY_DX
  N = 7;
  dy = rs.rand(size(y,1),Q,N);
  dx1 = feval([fcn '.backprop'],dy,x,y,settings);
  if (ndims(dx1) > 3) || any([size(dx1,1) size(dx1,2) size(dx1,3)]~=[Xsize Q N])
    err = [FCN '.backprop return values of incorrect size.'];
    return
  end
  dx2 = zeros(size(x,1),Q,N);
  for q=1:Q
    for i=1:N
      dx2(:,q,i) = dy_dx{q}' * dy(:,q,i);
    end
  end
  if max(abs(dx1(:)-dx2(:))) > 1e-9
    err = [FCN '.backprop returns values inconsistent with ' FCN '.dy_dx.'];
    return
  end
  
  % ---------- FCN.BACKPROP_REVERSE
  
  % BACKPROP_REVERSE package function must exist
  if isempty(nnpath.fcn2file([fcn,'.backpropReverse']))
    err = ['Package function +' FCN '/backpropReverse does not exist.'];
    return
  end

  % BACKPROP_REVERSE must be consistent with DY_DX
  dx = rs.rand(size(x,1),Q,N);
  dy1 = feval([fcn '.backpropReverse'],dx,x,y,settings);
  if (ndims(dy1) > 3) || any([size(dy1,1) size(dy1,2) size(dy1,3)]~=[Ysize Q N])
    err = [FCN '.backpropReverse return values of incorrect size.'];
    return
  end
  dy2 = zeros(size(y,1),Q,N);
  for q=1:Q
    for i=1:N
      dy2(:,q,i) = dx_dy{q}' * dx(:,q,i);
    end
  end
  if max(abs(dy1(:)-dy2(:))) > 1e-9
    err = [FCN '.backpropReverse returns values inconsistent with ' FCN '.dx_dy.'];
    return
  end
  
  % ---------- FCN.FORWARDPROP
  
  % FORWARDPROP package function must exist
  if isempty(nnpath.fcn2file([fcn,'.forwardprop']))
    err = ['Package function +' FCN '/forwardprop does not exist.'];
    return
  end
  
  % FORWARDPROP must be consistent with DY_DX
  dx = rs.rand(size(x,1),Q,N);
  dy1 = feval([fcn '.forwardprop'],dx,x,y,settings);
  if (ndims(dy1) > 3) || any([size(dy1,1) size(dy1,2) size(dy1,3)]~=[Ysize Q N])
    err = [FCN '.forwardprop return values of incorrect size.'];
    return
  end
  dy2 = zeros(size(y,1),Q,N);
  for q=1:Q
    for i=1:N
      dy2(:,q,i) = dy_dx{q} * dx(:,q,i);
    end
  end
  if max(abs(dy1(:)-dy2(:))) > 1e-9
    err = [FCN '.forwardprop returns values inconsistent with ' FCN '.dy_dx.'];
    return
  end
  
  % ---------- FCN.FORWARDPROP_REVERSE
  
  % FORWARDPROP_REVERSE package function must exist
  if isempty(nnpath.fcn2file([fcn,'.forwardpropReverse']))
    err = ['Package function +' FCN '/forwardpropReverse does not exist.'];
    return
  end
  
  % FORWARDPROP_REVERSE must be consistent with DY_DX
  N = 7;
  dy = rs.rand(size(y,1),Q,N);
  dx1 = feval([fcn '.forwardpropReverse'],dy,x,y,settings);
  if (ndims(dx1) > 3) || any([size(dx1,1) size(dx1,2) size(dx1,3)]~=[Xsize Q N])
    err = [FCN '.forwardpropReverse return values of incorrect size.'];
    return
  end
  dx2 = zeros(size(x,1),Q,N);
  for q=1:Q
    for i=1:N
      dx2(:,q,i) = dx_dy{q} * dy(:,q,i);
    end
  end
  if max(abs(dx1(:)-dx2(:))) > 1e-9
    err = [FCN '.forwardpropReverse returns values inconsistent with ' FCN '.dy_dx.'];
    return
  end
    
  % ---------- NNET 7.0 Backward Compatibility

  nnet7_fcns = {'fixunknowns','mapminmax','mapstd','processpca',...
    'removeconstantrows','removerows'};
  if ~isempty(nnstring.match(fcn,nnet7_fcns)), return; end
  
  % FCN('apply') must return same values as FCN.apply
  [y2,settings2] = feval(fcn,'apply',x,settings);
  if ~isa(y2,'double') || (ndims(y2) ~= 2)
    err = [FCN '(''apply'',x) does not return two dimensional double value.'];
    return
  end
  if (ndims(y)~=ndims(y2)) || any(y(:)~=y2(:))
    err = [FCN '(''apply'',x) does not return same values for default parameters and no parameters.'];
    return
  end
  
  % FCN('reverse') must return same values as FCN.reverse
  x2 = feval(fcn,'reverse',y,settings);
  if ~isa(x2,'double') || (ndims(x2) ~= 2)
    err = [FCN '.reverse does not return two dimensional double value.'];
    return
  end
  if (ndims(x2) ~= ndims(x)) || (any(size(x2) ~= size(x))) || any(abs(x2(:)-x(:))>1e-12)
    err = [FCN '.reverse is not consistent with ' FCN '.apply.'];
    return;
  end
  
  % FCN('dy_dx',...) must return same value as FCN.dy_dx(...)
  dy_dx2 = feval(fcn,'dy_dx',x,y,settings);
  if iscell(dy_dx2) ~= iscell(dy_dx)
    err = [FCN '(''dy_dx'',...) does not return same type as FCN.dy_dx(...).'];
    return
  end
  if (ndims(dy_dx2) ~= ndims(dy_dx)) || (any(size(dy_dx2) ~= size(dy_dx)))
    err = [FCN '(''dy_dx'',...) does not return same dimensions as FCN.dy_dx(...).'];
    return;
  end
  dy_dx_m = [dy_dx{:}];
  dy_dx2_m = [dy_dx2{:}];
  if (ndims(dy_dx2_m) ~= ndims(dy_dx_m)) || (any(size(dy_dx2_m) ~= size(dy_dx_m)))
    err = [FCN '(''dy_dx'',...) does not return elementes with same dimensions as FCN.dy_dx(...).'];
    return;
  end
  if max(max(abs(dy_dx_m-dy_dx2_m))) > 1e-9
    err = [FCN '(''dy_dx'',...) does not return same values as FCN.dy_dx(...).'];
    return
  end
  
  % FCN('dx_dy',...) must return same value as FCN.dx_dy(...)
  dx_dy2 = feval(fcn,'dx_dy',x,y,settings);
  if iscell(dx_dy2) ~= iscell(dx_dy)
    err = [FCN '(''dx_dy'',...) does not return same type as FCN.dx_dy(...).'];
    return
  end
  if (ndims(dx_dy2) ~= ndims(dx_dy)) || (any(size(dx_dy2) ~= size(dx_dy)))
    err = [FCN '(''dx_dy'',...) does not return same dimensions as FCN.dx_dy(...).'];
    return;
  end
  dx_dy_m = [dx_dy{:}];
  dx_dy2_m = [dx_dy2{:}];
  if (ndims(dx_dy2_m) ~= ndims(dx_dy_m)) || (any(size(dx_dy2_m) ~= size(dx_dy_m)))
    err = [FCN '(''dx_dy'',...) does not return elementes with same dimensions as FCN.dx_dy(...).'];
    return;
  end
  if max(max(abs(dx_dy_m-dx_dy2_m))) > 1e-9
    err = [FCN '(''dx_dy'',...) does not return same values as FCN.dx_dy(...).'];
    return
  end

  % ---------- NNET 6.0 Backward Compatibility
  
  % FCN('dy',...) must return same value as FCN.dy_dx(...)
  dy_dx2 = feval(fcn,'dy',x,y,settings);
  if iscell(dy_dx2) ~= iscell(dy_dx)
    err = [FCN '(''dy'',...) does not return same type as FCN.dy_dx(...).'];
    return
  end
  if (ndims(dy_dx2) ~= ndims(dy_dx)) || (any(size(dy_dx2) ~= size(dy_dx)))
    err = [FCN '(''dy'',...) does not return same dimensions as FCN.dy_dx(...).'];
    return;
  end
  dy_dx_m = [dy_dx{:}];
  dy_dx2_m = [dy_dx2{:}];
  if (ndims(dy_dx2_m) ~= ndims(dy_dx_m)) || (any(size(dy_dx2_m) ~= size(dy_dx_m)))
    err = [FCN '(''dy'',...) does not return elementes with same dimensions as FCN.dy_dx(...).'];
    return;
  end
  if max(max(abs(dy_dx_m-dy_dx2_m))) > 1e-9
    err = [FCN '(''dy'',...) does not return same values as FCN.dy_dx(...).'];
    return
  end
  
  % FCN('dx',...) must return same value as FCN.dx_dy(...)
  dx_dy2 = feval(fcn,'dx',x,y,settings);
  if iscell(dx_dy2) ~= iscell(dx_dy)
    err = [FCN '(''dx'',...) does not return same type as FCN.dx_dy(...).'];
    return
  end
  if (ndims(dx_dy2) ~= ndims(dx_dy)) || (any(size(dx_dy2) ~= size(dx_dy)))
    err = [FCN '(''dx'',...) does not return same dimensions as FCN.dx_dy(...).'];
    return;
  end
  dx_dy_m = [dx_dy{:}];
  dx_dy2_m = [dx_dy2{:}];
  if (ndims(dx_dy2_m) ~= ndims(dx_dy_m)) || (any(size(dx_dy2_m) ~= size(dx_dy_m)))
    err = [FCN '(''dx'',...) does not return elementes with same dimensions as FCN.dx_dy(...).'];
    return;
  end
  if max(max(abs(dx_dy_m-dx_dy2_m))) > 1e-9
    err = [FCN '(''dx'',...) does not return same values as FCN.dx_dy(...).'];
    return
  end
  
end

function x = strict_format(x)
end
