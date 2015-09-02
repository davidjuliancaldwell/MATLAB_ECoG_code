classdef nnfcnTraining < nnfcnInfo
%NNTRAININGFCNINFO Training function info.

% Copyright 2010-2012 The MathWorks, Inc.

  properties (SetAccess = private)
    isSupervised = false;
    usesGradient = false;
    usesJacobian = false;
    usesDerivative = false;
    usesValidation = false;
    supportsCalcModes = true;
    states = [];
  end
    
  methods
    
    function x = nnfcnTraining(mfunction,name,version, ...
        isSupervised,usesGradient,usesJacobian,usesValidation,...
        supportsCalcModes,param,states)
      
      if nargin < 4, error(message('nnet:Args:NotEnough')); end
      if ~nntype.bool_scalar('isa',isSupervised)
        error(message('nnet:nnfcnTraining:IsSupervised'));
      elseif ~nntype.bool_scalar('isa',usesValidation)
        error(message('nnet:nnfcnTraining:UsesValidation'));
      end
      if ~isempty(param) && ~isa(param,'nnetParamInfo') && ~isstruct(param)
        error(message('nnet:nnfcnTraining:ParamsNotArray'));
      end
      
      x = x@nnfcnInfo(mfunction,name,'nntype.training_fcn',version);
      
      x.isSupervised = isSupervised;
      x.usesGradient = usesGradient;
      x.usesJacobian = usesJacobian;
      x.usesDerivative = x.usesGradient || x.usesJacobian;
      x.usesValidation = usesValidation;
      x.supportsCalcModes = supportsCalcModes;
      x.states = states;
      x.setupParameters(param);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      disp@nnfcnInfo(x)
      disp([nnlink.prop2link('isSupervised') nnstring.bool2str(x.isSupervised)]);
      disp([nnlink.prop2link('usesGradient') nnstring.bool2str(x.usesGradient)]);
      disp([nnlink.prop2link('usesJacobian') nnstring.bool2str(x.usesJacobian)]);
      disp([nnlink.prop2link('usesDerivative') nnstring.bool2str(x.usesDerivative)]);
      disp([nnlink.prop2link('usesValidation') nnstring.bool2str(x.usesValidation)]);
      disp([nnlink.prop2link('supportsCalcModes') nnstring.bool2str(x.supportsCalcModes)]);
      disp([nnlink.prop2link('trainingStates') nnlink.states2str(x.states)]);
      if (isLoose), fprintf('\n'), end
    end
    
    % NNET 6.0 Compatibility
    function gd = gdefaults(x)
      gd = 'defaultderiv';
    end
  end
  
end


