classdef nnfcnSearch < nnfcnInfo
%NNSEARCHFCNINFO Propagation function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnSearch(name,title,version)
      if nargin < 3, error(message('nnet:Args:NotEnough')); end
      
      x = x@nnfcnInfo(name,title,'nntype.search_fcn',version);
      
      % TODO Parameters
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnSearch">nnfcnSearch</a>')
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
