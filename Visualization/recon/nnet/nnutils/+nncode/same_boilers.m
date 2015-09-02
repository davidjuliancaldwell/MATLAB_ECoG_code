function same_boilers(malfunction)
%SAME_BOILERS Returns true if functions have same boiler.

% Copyright 2010 The MathWorks, Inc.

info = feval(mfunction,'info');
type = info.type;
registry = nnregistry.info;
functions = registry.(type).functions;

[boiler1,heading1] = nn_getboiler(mfunction);
if isempty(boiler1)
  disp([mfunction ' HAS NO BOILER.']);
  return;
end

disp(' ')
for i=1:length(functions)
  f = functions{i};
  if ~strcmp(mfunction,f);
    [boiler2,heading2] = nn_getboiler(f);
    if isempty(boiler2)
      disp([mfunction ': ' f ' HAS NO BOILER.']);
      continue;
    end
    
    if strcmp(heading2,nn_str_replace(heading1,mfunction,f))
      disp([mfunction ': ' f ' heading is same.'])
    else
      disp([mfunction ': ' f ' heading is DIFFERENT.']);
    end  
    if nn_textcmp(boiler1,boiler2)
      disp([mfunction ': ' f ' boiler is same.'])
    else
      disp([mfunction ': ' f ' boiler is DIFFERENT.']);
    end
  end
end
