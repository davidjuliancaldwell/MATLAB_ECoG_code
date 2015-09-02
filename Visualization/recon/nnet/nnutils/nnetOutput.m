classdef nnetOutput

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    name = 'Output';
    feedbackInput = [];
    feedbackDelay = 0;
    feedbackMode = 'none';
    processFcns = cell(1,0);
    processParams = cell(1,0);
    processSettings = cell(1,0);
    processedRange = zeros(0,2);
    processedSize = 0;
    range = zeros(0,2);
    size = 0;
    userdata = struct;
    
    % NNET 6.0 Compatibility
    exampleOutput = [];
  end
  
  methods
    
    function x = nnetOutput(s)
      x = nnconvert.struct2obj(x,s);
    end
        
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if numel(x) == 0
        disp('    Empty array of Neural Network Outputs.');
      elseif numel(x) > 1
        disp(['    Array of ' num2str(numel(x)) ' Neural Network Outputs.'])
      else
        xfbi = '[]';
        if ~isempty(x.feedbackInput), xfbi = num2str(x.feedbackInput); end
        
        disp('    Neural Network Output');
        if (isLoose), fprintf('\n'), end
        disp([nnlink.prop2link('output','name') nnstring.str2str(x.name)]);
        disp([nnlink.prop2link('output','feedbackInput') xfbi]);
        disp([nnlink.prop2link('output','feedbackDelay') nnstring.num2str(x.feedbackDelay)]);
        disp([nnlink.prop2link('output','feedbackMode') nnstring.str2str(x.feedbackMode)]);
        disp([nnlink.prop2link('output','processFcns') nnlink.fcns2links(x.processFcns)]);
        disp([nnlink.prop2link('output','processParams') nnstring.objs2str(x.processParams,'nnetParam')]);
        disp([nnlink.prop2link('output','processSettings') nnstring.objs2str(x.processSettings,'nnetSetting')]);
        disp([nnlink.prop2link('output','processedRange') nnstring.num2str(x.processedRange)]);
        disp([nnlink.prop2link('output','processedSize') nnstring.num2str(x.processedSize)]);
        disp([nnlink.prop2link('output','range') nnstring.num2str(x.range)]);
        disp([nnlink.prop2link('output','size') nnstring.num2str(x.size)]);
        disp([nnlink.prop2link('output','userdata') '(your custom info)']);
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
