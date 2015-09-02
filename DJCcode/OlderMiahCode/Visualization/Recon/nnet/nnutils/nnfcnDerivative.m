classdef nnfcnDerivative < nnfcnInfo
%NNDERIVATIVEFCNINFO Derivative function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnDerivative(name,title,version,subfunctions)
      if nargin < 3, error(message('nnet:Args:NotEnough')); end
      
      x = x@nnfcnInfo(name,title,'nntype.derivative_fcn',...
        version,subfunctions);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnDerivative">nnfcnDerivative</a>')
      fprintf('\n')
      %=======================:
      disp('           (none)');
    end
    
  end
  
end
