function str = paramstruct2str(x,doLinks)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2
  doLinks = true;
end

x = struct(x);

f = fieldnames(x);
n = length(f);
if n == 0
  str = '(none)';
else
  fi = f{1};
  if doLinks
    str = ['.' nnlink.paramname2linkstr(fi)];
  else
    str = ['.' fi];
  end
  len = 1 + length(fi);
  for i=2:n
    str = [str ','];
    len = len + 1;
    fi = f{i};
    if doLinks
      xi = nnlink.paramname2linkstr(fi);
    else
      xi = fi;
    end
    if (len + 2 + length(fi)) > 50
      str = [str '\n                    .' xi];
      len = 1 + length(fi);
    else
      str = [str ' .' xi];
      len = len + 2 + length(fi);
    end
  end
end

str = sprintf(str);
