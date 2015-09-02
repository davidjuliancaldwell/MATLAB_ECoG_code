classdef nnetBias

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    initFcn = '';
    learn = true;
    learnFcn = '';
    learnParam = nnetParam;
    size = 0;
    userdata = struct;
  end
  
  methods
    
    function x = nnetBias(s)
      x = nnconvert.struct2obj(x,s);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if numel(x) == 0
        disp('    Empty array of Neural Network Biases.');
      elseif numel(x) > 1
        disp(['    Array of ' num2str(numel(x)) ' Neural Network Biases.'])
      else
        disp('    Neural Network Bias');
        if (isLoose), fprintf('\n'), end
        disp([nnlink.prop2link('bias','initFcn') nnlink.fcn2strlink(x.initFcn)]);
        disp([nnlink.prop2link('bias','learn') nnstring.bool2str(x.learn)]);
        disp([nnlink.prop2link('bias','learnFcn') nnlink.fcn2strlink(x.learnFcn)]);
        disp([nnlink.prop2link('bias','learnParam') nnlink.paramstruct2str(x.learnParam)]);
        disp([nnlink.prop2link('bias','size') num2str(x.size)]);
        disp([nnlink.prop2link('bias','userdata') '(your custom info)']);
      end
      if (isLoose), fprintf('\n'), end
    end
        
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
