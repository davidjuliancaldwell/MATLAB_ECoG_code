function out1 = weight_fcn(fcn,varargin)
%NNET7.WEIGHT_FCN Weight function NNET 7.0 backward compatibility

% Copyright 2012 The MathWorks, Inc.

info = nnModuleInfo(fcn);
in1 = varargin{1};
switch(in1)

  % NNET 7.0 Compatibility
  
  case 'apply'
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 2, error(message('nnet:Args:NotEnough')); end
    w = nntype.matrix_data('format',args{1},'Weight');
    p = nntype.matrix_data('format',args{2},'Inputs');
    out1 = apply(w,p,param);

  case 'dz_dp'
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 2, error(message('nnet:Args:NotEnough')); end
    w = nntype.matrix_data('format',args{1},'Weight');
    p = nntype.matrix_data('format',args{2},'Inputs');
    if nargs < 3
      z = apply(w,p,INFO.defaultParam);
    else
      z = nntype.matrix_data('format',args{3},'Net input');
    end
    out1 = dz_dp(w,p,z,param);

  case 'dz_dw'
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 2, error(message('nnet:Args:NotEnough')); end
    w = nntype.matrix_data('format',args{1},'Weight');
    p = nntype.matrix_data('format',args{2},'Inputs');
    if nargs < 3
      z = apply(w,p,INFO.defaultParam);
    else
      z = nntype.matrix_data('format',args{3},'Net input');
    end
    out1 = dz_dw(w,p,z,param);
    
  case {'info','subfunctions'}
    out1 = info;
    
  case 'defaultParam'
    out1 = info.defaultParam;
    
  case 'fpnames'
    out1 = fieldnames(info.defaultParam);
    
  case 'name'
    out1 = info.name;
    
  case 'size',
    % this('size',numNeurons,numInputs')
    % Weight size
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 2, error(message('nnet:Args:NotEnough')); end
    s = nntype.pos_int_scalar('format',args{1},'Layer size');
    r = nntype.pos_int_scalar('format',args{2},'Input size');
    out1 = info.size(s,r,param);
    
  % NNET 6.0 Compatibility
      
  case 'pfullderiv', out1 = info.inputDerivType;
  case 'wfullderiv', out1 = info.weightDerivType;
  case 'check',
    if nargin < 2,error(message('nnet:Args:NotEnough')); end
    out1 = check_param(varargin{2});      
  case 'dp'
    if nargin < 4,error(message('nnet:Args:NotEnough')); end
    if nargin < 6, varargin{5} = info.defaultParam; end
    out1 = info.dz_dp(varargin{2:5});
  case 'dw'
    if nargin < 4,error(message('nnet:Args:NotEnough')); end
    if nargin < 6, varargin{5} = info.defaultParam; end
    out1 = info.dz_dw(varargin{2:5});
    
  case 'simulinkParameters'
    out1 = info.simulinkParameters(varargin{2:end});
end
