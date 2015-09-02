classdef nnetSetting

% Copyright 2010-2011 The MathWorks, Inc.
  
  properties
    fcn = '';
    values = struct;
  end
  
  methods
    
    function x = nnetSetting(fcn,values)
      if nargin == 0
        x.fcn = '';
        x.values = struct;
      elseif nargin == 2 
        x.fcn = fcn;
        if ~ischar(fcn), error(message('nnet:FcnName:NotString')); end
        if isempty(values)
          values = struct;
        elseif isa(values,'nnetSetting')
          values = struct(values);
        elseif ~isstruct(values)
          keyboard
          error(message('nnet:nnetSetting:NotStruct'));
        end
        x.values = values;
      else
        error(message('nnet:Args:IncorrectNum'));
      end
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if (isLoose), fprintf('\n'), end
      if isempty(x.fcn)
        disp('    No Neural Function Settings');
      elseif isempty(fieldnames(x.values))
        disp(['    No Function Settings for ' nnlink.fcn2ulink(upper(x.fcn))]);
      else
        disp(['    Function Settings for ' nnlink.fcn2ulink(upper(x.fcn))]);
        if (isLoose), fprintf('\n'), end
        fields = fieldnames(x.values);
        maxLen = 0;
        for i=1:length(fields)
          maxLen = max(maxLen,length(fields{i}));
        end
        for i=1:length(fields)
          fi = fields{i};
          sp = nnstring.spaces(maxLen-length(fi));
          disp(['    ' sp nnlink.prop2link2(fi) ': ' nnstring.fieldvalue2str(x.values.(fi))]);
        end
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function x = subsref(x,s)
      x = subsref(x.values,s);
    end
    
    function x = subsasgn(x,s,v)
      error(message('nnet:nnetSetting:ReadOnly'));
    end
    
    function fn = fieldnames(x)
      fn = fieldnames(x.values);
    end
    
    function s = struct(x)
      s = x.values;
    end
    
    function flag = isempty(x)
      flag = isempty(fieldnames(x.values));
    end
  end
end
