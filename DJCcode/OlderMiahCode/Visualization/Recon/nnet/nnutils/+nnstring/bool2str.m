function s = bool2str(b)

% Copyright 2010 The MathWorks, Inc.

if isempty(b)
  s = '[]';
elseif numel(b) == 1
  if (b)
    s = 'true';
  else
    s = 'false';
  end
elseif numel(b) > 12
  s = sprintf('[%gx%g boolean]',size(b,1),size(b,2));
else
  s = '[';
  for i=1:size(b,1)
    if (i > 1)
      s = [s '; '];
    end
    for j=1:size(b,2)
      if (j > 1)
        s = [s sprintf(' %g',b(i,j))];
      else
        s = [s sprintf('%g',b(i,j))];
      end
    end
  end
  s = [s ']'];
end
