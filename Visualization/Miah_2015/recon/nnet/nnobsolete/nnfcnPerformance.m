classdef nnfcnPerformance < nnfcnInfo
%NNPERFORMANCEFCNINFO Data Division function info.

% Copyright 2010-2012 The MathWorks, Inc.

  properties (SetAccess = private)
  end
  
  % TODO - User PERFORM to calculate performance
  % TODO - Take T instead of E, support weighted errors
  % TODO - Make regulurization, normalization, economization orthogonal
  
  methods
    
    function x = nnfcnPerformance(name,title,version,subfunctions,param)
      
      if nargin < 5, error(message('nnet:Args:NotEnough')); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        error(message('nnet:nnfcnPerformance:ParamsNotArray'));
      end
      
      x = x@nnfcnInfo(name,title,'nntype.performance_fcn',version,subfunctions);
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
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
