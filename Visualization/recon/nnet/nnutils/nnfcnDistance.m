classdef nnfcnDistance < nnfcnInfo
%NNDISTANCEFCNINFO Distance function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
    isContinuous = true;
    inputDerivType = 0;
    weightDerivType = 0;
  end
  
  methods
    
    function x = nnfcnDistance(name,title,version,subfunctions, ...
       isContinuous,inputDerivType,weightDerivType,param)
      x = x@nnfcnInfo(name,title,'nntype.distance_fcn',version,subfunctions);
      x.isContinuous = isContinuous;
      x.inputDerivType = inputDerivType;
      x.weightDerivType = weightDerivType;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnDistance">Distance Function Info</a>')
      fprintf('\n')
      disp(['      isWeightFcn: ' bool2str(x.inputDerivType)]);
      disp(['   inputDerivType: ' num2str(x.inputDerivType)]);
      disp(['  weightDerivType: ' num2str(x.weightDerivType)]);
      disp(['       parameters: ' params2str(x.parameters)]);
    end
    
  end
  
end

function s = bool2str(x)
  if x, s = 'true'; else s = 'false'; end
end

function s = params2str(p)
  n = length(p);
  if n == 0
    s = '(none)';
  else
    s = ['[1x' num2str(n) ' nnetParamInfo]'];
  end
end
