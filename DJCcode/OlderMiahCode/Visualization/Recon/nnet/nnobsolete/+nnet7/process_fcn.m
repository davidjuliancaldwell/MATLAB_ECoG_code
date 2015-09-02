function [out1,out2] = process_fcn(fcn,varargin)
%NNET7.PROCESS_FCN Transfer function NNET 7.0 backward compatibility

% Copyright 2012 The MathWorks, Inc.

out2 = [];
info = nnModuleInfo(fcn);
in1 = varargin{1};
switch(in1)

  % NNET 7.0 Compatibility

  case 'create'
    [args,param] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
    [x,ii,jj,wasCell] = nncell2mat(args{1});
    [out1,out2] = info.create(x,param);
    if (wasCell), out1 = mat2cell(out1,ii,jj); end

  case 'apply'
    out2 = varargin{3};
    if out2.no_change
      out1 = varargin{2};
    else
      [in2,ii,jj,wasCell] = nncell2mat(varargin{2});
      out1 = info.apply(in2,out2);
      if (wasCell), out1 = mat2cell(out1,ii,jj); end
    end

  case 'reverse'
    out2 = varargin{3};
    if out2.no_change
      out1 = varargin{2};
    else
      [in2,ii,jj,wasCell] = nncell2mat(varargin{2});
      out1 = info.reverse(in2,out2);
      if (wasCell), out1 = mat2cell(out1,ii,jj); end
    end

  case 'dy_dx'
    out1 = info.dy_dx(varargin{2:4});

  case 'dx_dy'
    out1 = info.dx_dy(varargin{2:4});

  case {'info','subfunctions'}
    out1 = info;
    
  case 'defaultParam'
    out1 = info.defaultParam;

  case 'pdefaults'
    out1 = info.defaultParam;

  case 'pdesc'
    out1 = info.name;

  case 'pcheck'
    out1 = true;
    
  case 'simulinkParameters'
    out1 = feval(info.simulinkParameters,varargin{2});
    
  case {'simulinkParametersReverse', 'simulinkParametersReverse'}
    out1 = feval(info.simulinkParametersReverse,varargin{2});
  
  % NNET 6.0 Compatibility

  case 'dx'
    out1 = info.dy_dx(varargin{2:4});
    
  case 'dy'
    out1 = info.dy_dx(varargin{2:4});
end

