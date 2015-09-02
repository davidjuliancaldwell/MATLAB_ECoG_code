classdef nnfcnLearning < nnfcnInfo
%NNLAYERINITFCNINFO Layer initialization function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
    learnBias = true;
    learnInputWeight = false;
    learnLayerWeight = false;
    needGradient = false;
  end
  
  % TODO - Methods for getting and checking initial settings
  
  methods
    
    function x = nnfcnLearning(mfunction,name,version,subfunctions,...
        b,iw,lw,g,param)
      if nargin < 8, error(message('nnet:Args:NotEnough')); end
      if ~nntype.bool_scalar('isa',b),error(message('nnet:nnfcnLearning:LearnB')); end
      if ~nntype.bool_scalar('isa',iw),error(message('nnet:nnfcnLearning:LearnIW')); end
      if ~nntype.bool_scalar('isa',lw),error(message('nnet:nnfcnLearning:learnLW')); end
      if ~nntype.bool_scalar('isa',g),error(message('nnet:nnfcnLearning:NeedGradient')); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        error(message('nnet:nnfcnLearning:ParamsNotArray'));
      end
      
      x = x@nnfcnInfo(mfunction,name,'nntype.learning_fcn',version,subfunctions);
      
      x.learnBias = b;
      x.learnInputWeight = iw;
      x.learnLayerWeight = lw;
      x.needGradient = g;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnLearning">Learning Function Info</a>')
      fprintf('\n')
      %=======================:
      disp(['        learnBias: ' nnstring.bool2str(x.learnBias)]);
      disp([' learnInputWeight: ' nnstring.bool2str(x.learnInputWeight)]);
      disp([' learnLayerWeight: ' nnstring.bool2str(x.learnLayerWeight)]);
      disp(['     needGradient: ' nnstring.bool2str(x.needGradient)]);
      disp(['       parameters: ' nnstring.params2str(x.parameters)]);
    end
    
    % NNET 6.0 Compatibility
    function ng = needg(x)
      ng = x.needGradient;
    end
      
  end
  
end
