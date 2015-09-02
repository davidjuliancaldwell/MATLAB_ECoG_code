function str = fcns2links(fcns)

% Copyright 2010 The MathWorks, Inc.

if isempty(fcns)
  str = '{}';
else
  fi = fcns{1};
  str = ['{' nnlink.fcn2strlink(fi);];
  len = 3 + length(fi) + 2;
  for i=2:length(fcns)
    fi = fcns{i};
    xi = nnlink.fcn2link(fi);
    if (len + 4 + length(fi)) > 50
      str = [str ',\n                    ' xi];
      len = 2 + length(fi);
    else
      str = [str ', ' xi];
      len = len + 4 + length(fi);
    end
  end
  str = [str '}'];
end

str = sprintf(str);
