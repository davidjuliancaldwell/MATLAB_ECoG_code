classdef nnfcnWizard < nnfcnInfo

% Copyright 2010 The MathWorks, Inc.
  
  properties
  end
  
  methods
    
    function x = nnfcnWizard(name,title,version)
      if nargin < 3,error(message('nnet:Args:NotEnough')); end
      x = x@nnfcnInfo(name,title,'nntype.wizard_fcn',version);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnWizard">nnfcnWizard</a>')
      fprintf('\n')
      %=======================:
      disp('           (none)');
    end
    
  end
  
end

function s = params2str(p)
  n = length(p);
  if n == 0
    s = '(none)';
  else
    s = ['[1x' num2str(n) ' <a href="matlab:doc nnetParamInfo">nnetParamInfo</a> array]'];
  end
end
