function str = nn_remove_str_whitespace(str)

% Copyright 2010 The MathWorks, Inc.

str2 = str;
pos = 0;
mode = -1;

% Process the rest
for i=1:length(str)
  c = str(i);
  switch mode
    
    case -1, % keep initial whitespace
      if (c==32) || (c==8)
        pos = pos + 1;
        str2(pos) = ' ';
      elseif (c == '%')
        break;
      elseif (c == '''')
        pos = pos + 1;
        str2(pos) = ' ';
        mode = 2;
      else
        pos = pos + 1;
        str2(pos) = c;
        mode = 0;
      end
      
    case 0, % normal
      if (c == '%')
        break;
      elseif (c==32) || (c==8)
        pos = pos + 1;
        str2(pos) = ' ';
        mode = 1;
      elseif c == ''''
        pos = pos+1;
        str2(pos) = c;
        mode = 2;
      else
        pos = pos+1;
        str2(pos) = c;
      end
      
    case 1, % skipping whitespace
      if (c ~= 32) && (c ~= 8)
        pos = pos+1;
        str2(pos) = c;
        mode = 0;
      end
      
    case 2, % traversing string
      pos = pos + 1;
      str2(pos) = c;
      if (c == '''')
        mode = 0;
      end
    
  end
end

% Skip back over final whitespace
for i=pos:-1:1
  c = str2(pos);
  if (c~=32) && (c~=8)
    break;
  end
  pos = pos-1;
end

str = str2(1:pos);
