function text = nn_getsubfunction(mf,sf)
%GET_SUBFUNCTION Get subfunction code from function.

% Copyright 2010 The MathWorks, Inc.

text = nn_getmtext(mf);
text = nn_codetextonly(text);

start = 0;
for i=1:length(text)
  ti = text{i};
  if nnstring.starts(ti,'function')
    if ~isempty(strfind(ti,sf))
      start = i;
      break;
    end
  end
end

if start == 0
  text = {};
  return;
end

stop = 0;
for i=(start+1):length(text)
  ti = text{i};
  if nnstring.starts(ti,'function')
    stop = i-1;
    break;
  end
end
if stop == 0
  stop = length(text);
end

text = text(start:stop);

if ~strcmp(text{end},'end')
  nnerr.throw(['Subfunction ' mf '.' sf ' does not terminate with an ''end'' statement.']);
end
