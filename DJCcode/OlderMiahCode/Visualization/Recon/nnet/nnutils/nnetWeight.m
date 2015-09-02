classdef nnetWeight

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    delays = 0;
    initFcn = '';
    initSettings = [];
    learn = 1;
    learnFcn = '';
    learnParam = nnetParam;
    size = [0 0];
    userdata = struct;
    weightFcn = 'dotprod';
    weightParam = struct;
  end
  
  methods
    
    function x = nnetWeight(s)
      x = nnconvert.struct2obj(x,s);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if numel(x) == 0
        disp('    Empty array of Neural Network Weights.');
      elseif numel(x) > 1
        disp(['    Array of ' num2str(numel(x)) ' Neural Network Weights.'])
      else
        disp('    Neural Network Weight');
        if (isLoose), fprintf('\n'), end
        disp([nnlink.prop2link('weight','delays') nnstring.int2str(x.delays)]);
        disp([nnlink.prop2link('weight','initFcn') nnlink.fcn2strlink(x.initFcn)]);
        disp([nnlink.prop2link('weight','initSettings') nnlink.paramstruct2str(x.initSettings)]);
        disp([nnlink.prop2link('weight','learn') nnstring.bool2str(x.learn)]);
        disp([nnlink.prop2link('weight','learnFcn') nnlink.fcn2strlink(x.learnFcn)]);
        disp([nnlink.prop2link('weight','learnParam') nnlink.paramstruct2str(x.learnParam)]);
        disp([nnlink.prop2link('weight','size') nnstring.int2str(x.size)]);
        disp([nnlink.prop2link('weight','weightFcn') nnlink.fcn2strlink(x.weightFcn)]);
        disp([nnlink.prop2link('weight','weightParam') nnlink.paramstruct2str(x.weightParam)]);
        disp([nnlink.prop2link('weight','userdata') '(your custom info)']);
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
