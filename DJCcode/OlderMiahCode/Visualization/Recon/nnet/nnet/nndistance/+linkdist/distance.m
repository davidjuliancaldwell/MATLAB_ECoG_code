function d = distance(pos,param)

% Copyright 2012 The MathWorks, Inc.

s = size(pos,2);
found = eye(s,s);
links = double((dist(pos) <= 1.00001) & ~found);
d = s*(1-eye(s,s));
for i=1:s
  nextfound = (found*links) | found;
  newfound = nextfound & ~found;
  ind = find(newfound);
  if isempty(ind)
    break;
  end
  d(ind) = i;
  found = nextfound;
end
