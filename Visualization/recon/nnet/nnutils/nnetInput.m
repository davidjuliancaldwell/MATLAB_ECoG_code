classdef nnetInput

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    name = 'Input';
    feedbackOutput = [];
    processFcns = cell(1,0);
    processParams = cell(1,0);
    processSettings = cell(1,0);
    processedRange = zeros(0,2);
    processedSize = 0;
    range = zeros(0,2);
    size = 0;
    userdata = struct;
    
    % NNET 6.0 Compatibility
    exampleInput = [];
  end
  
  methods
    
    function x = nnetInput(s)
      x = nnconvert.struct2obj(x,s);
    end
        
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      %if (isLoose), fprintf('\n'), end
      
      if isempty(x.feedbackOutput)
        xfbo = '[]';
      else
        xfbo = num2str(x.feedbackOutput);
      end
      if numel(x) == 0
        disp('    Empty array of Neural Network Inputs.');
      elseif numel(x) > 1
        disp(['    Array of ' num2str(numel(x)) ' Neural Network Inputs.'])
      else
        disp('    Neural Network Input');
        if (isLoose), fprintf('\n'), end
        disp([nnlink.prop2link('input','name') nnstring.str2str(x.name)]);
        disp([nnlink.prop2link('input','feedbackOutput') xfbo]);
        disp([nnlink.prop2link('input','processFcns') nnlink.fcns2links(x.processFcns)]);
        disp([nnlink.prop2link('input','processParams') nnstring.objs2str(x.processParams,'nnetParam')]);
        disp([nnlink.prop2link('input','processSettings') nnstring.objs2str(x.processSettings,'nnetSetting')]);
        disp([nnlink.prop2link('input','processedRange') nnstring.num2str(x.processedRange)]);
        disp([nnlink.prop2link('input','processedSize') num2str(x.processedSize)]);
        disp([nnlink.prop2link('input','range') nnstring.num2str(x.range)]);
        disp([nnlink.prop2link('input','size') nnstring.num2str(x.size)]);
        disp([nnlink.prop2link('input','userdata') '(your custom info)']);
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
