classdef nnfcnAdaptive < nnfcnInfo
%NNADAPTIVEFCNINFO Adaptive function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    isSupervised = false;
    usesGradient = false;
  end
  
  methods
    
    function x = nnfcnAdaptive(name,title,version, ...
        isSupervised,usesGradient,param)
      
      if nargin < 6, error(message('nnet:Args:NotEnough')); end
      if ~nntype.bool_scalar('isa',isSupervised)
        error(message('nnet:nnfcnAdaptive:IsSupervised'));
      elseif ~nntype.bool_scalar('isa',usesGradient)
        error(message('nnet:nnfcnAdaptive:UsesGradient'));
      end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        error(message('nnet:nnfcnAdaptive:ParamsNotArray'));
      end
      
      x = x@nnfcnInfo(name,title,'nntype.adaptive_fcn',version);
      
      x.isSupervised = isSupervised;
      x.usesGradient = usesGradient;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnAdaptive">nnfcnTraining</a>')
      fprintf('\n')
      %=======================:
      disp(['     isSupervised: ' bool2str(x.isSupervised)]);
      disp(['     usesGradient: ' bool2str(x.usesGradient)]);
      disp(['       parameters: ' params2str(x.parameters)]);
    end
    
  end
  
end

function s = bool2str(b)
  if (b)
    s = 'true';
  else
    s = 'false';
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

function s = states2str(p)
  n = length(p);
  if n == 0
    s = '(none)';
  else
    s = ['[1x' num2str(n) ' states array]'];
  end
end
