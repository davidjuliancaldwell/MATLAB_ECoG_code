classdef nnetParamInfo

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
    fieldname = '';
    title = '';
    description = '';
    type = '';
    default = [];
  end
  
  methods
    
    function x = nnetParamInfo(fieldname,title,type,default,desc)
      
      if ~nntype.string('isa',fieldname),error(message('nnet:FieldName:NotString')); end
      if ~nntype.string('isa',title),error(message('nnet:nnetParamInfo:Title')); end
      if ~nntype.string('isa',type),error(message('nnet:nnetParamInfo:Type')); end % TODO
      if ~nntype.string('isa',desc),error(message('nnet:nnetParamInfo:Description')); end % TODO
      
      if ~exist(fcn2filename(type),'file') % TODO - check registry, not filesystem
        nnerr.throw(['Type ''' type ''' does not exist.']);
      end
      err = feval(type,'check',default);
      if ~isempty(err)
        disp(['Default value is not a member of type "' type '".']);
        nnerr.throw(nnerr.value(err,['Default ' fieldname]))
      end
      
      x.fieldname = fieldname;
      x.title = title;
      x.description = desc;
      x.type = type;
      x.default = default;
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if numel(x) == 1
        disp(' nnetParamInfo')
        if (isLoose), fprintf('\n'), end
        disp(['        fieldname: ' str2str(x.fieldname)]);
        disp(['            title: ' str2str(x.title)]);
        disp(['      description: ' str2str(x.description)]);
        disp(['             type: ' str2str(x.type)]);
        disp(['          default: ' any2str(x.default)]);
      else
        disp(['  [' num2str(size(x,1)) 'x' num2str(size(x,2)) ' nnetParamInfo array]']);
      end
      if (isLoose), fprintf('\n'), end
    end
    
  end
    
end

function s = str2str(s)
s = ['''' s ''''];
end

function s = any2str(x)
  if isnumeric(x) || islogical(x)
    if isempty(x)
      s = '[]';
    elseif numel(x) == 1
      s = num2str(x);
    else
      sizes = size(x);
      d = num2str(size(1));
      for i=2:length(sizes)
        d = [d 'x' num2str(sizes(i))];
      end
      s = ['[' d ' ' class(x) ']'];
    end
  else
    s = ['<' class(x) ' value>'];
  end
end

function filename = fcn2filename(fcn)
  dot = find(fcn == '.',1);
  if isempty(dot)
    filename = fcn;
  else
    filename = ['+' fcn(1:(dot-1)) filesep fcn((dot+1):end)];
  end
end
