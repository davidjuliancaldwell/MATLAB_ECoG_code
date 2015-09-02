function out1 = net_input_fcn(fcn,varargin)
%NNET7.NET_INPUT_FCN Net input function NNET 7.0 backward compatibility

% Copyright 2012 The MathWorks, Inc.

info = nnModuleInfo(fcn);
in1 = varargin{1};
switch(in1)

  % NNET 7.0 Compatibility

  case 'apply'
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 1, error(message('nnet:Args:NotEnough')); end
    z = args{1};
    out1 = info.apply(z,size(z{1},1),size(z{1},2),param);

  case 'dn_dzj'
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 2, error(message('nnet:Args:NotEnough')); end
    j = nntype.pos_int_scalar('format',args{1},'Input index');
    z = args{2};
    if nargs < 3
      n = info.apply(z,size(z{1},1),size(z{1},2),param);
    else
      n = nntype.matrix_data('format',args{3},'Net input');
    end
    out1 = info.dn_dzj(j,z,n,param);

  case {'info','subfunctions'}
    out1 = info;

  case 'outputRange'
    out1 = info.outputRange;
    
  case 'defaultParam'
    out1 = info.defaultParam;
    
  case 'simulinkParameters'
    out1 = feval([fcn '.simulinkParameters'],varargin{2:end});

  % NNET 6.0 Compatibility

  case 'dz',
    if (nargin < 5) || isempty(varargin{5}), varargin{5} = info.defaultParam; end
    out1 = info.dn_dzj(varargin{2:5});
end
