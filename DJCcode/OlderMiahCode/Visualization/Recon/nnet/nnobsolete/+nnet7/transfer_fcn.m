function out1 = transfer_fcn(fcn,varargin)
%NNET7.TRANSFER_FCN Transfer function NNET 7.0 backward compatibility

% Copyright 2012 The MathWorks, Inc.

info = nnModuleInfo(fcn);
in1 = varargin{1};
switch(in1)

  % NNET 7.0 Compatibility

  case 'apply'
    % this('apply',n,...*param...)
    % Apply transfer function to net inputs
    % Equivalent to: this(n,...*param...)
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 1, error(message('nnet:Args:NotEnough')); end
    n = nntype.matrix_data('format',args{1},'Net input');
    out1 = info.apply(n,param);

  case 'da_dn'
    % this('da_dn',n,*a,...*param...)
    % Calculate da/dn analytically
    % Derivative may be returned in matrix form (for scalar functions)
    % or cell form (for general functions).
    [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
    if nargs < 1, error(message('nnet:Args:NotEnough')); end
    n = nntype.matrix_data('format',args{1},'Net input');
    if nargs < 2
      a = info.apply(n,info.defaultParam);
    else
      a = nntype.matrix_data('format',args{2},'Layer output');
      if any(size(n) ~= size(a))
        error(message('nnet:NNData:NAMismatch'));
      end
    end
    out1 = info.da_dn(n,a,param);

  case {'info','subfunctions'}
    out1 = info;
    
  case 'defaultParam'
    out1 = info.defaultParam;

  case {'outputRange','output'}
    out1 = info.outputRange;
    
  case {'activeInputRange','active'}
    out1 = info.activeInputRange;
    
  case 'name'
    out1 = info.name;
    
  % NNET 6.0 Compatibility

  case 'dn'
    n = varargin{2};
    if nargin < 5
      param = info.defaultParam;
    else
      param = varargin{4};
    end
    if nargin < 4
      a = info.apply(n,param);
    else
      a = varargin{3};
    end
    out1 = info.da_dn(n,a,param);
    
  case 'simulinkParameters'
     out1 = feval([fcn '.simulinkParameters'],varargin{2:end});
end
