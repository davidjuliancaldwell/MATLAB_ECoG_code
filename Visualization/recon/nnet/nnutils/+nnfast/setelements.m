function x = setelements(x,ind,v)
%SETELEMENTS_FAST (STRICTNNDATA,INDICES,STRICTNNDATA) => STRICTNNDATA

% Copyright 2010 The MathWorks, Inc.

[S,TS] = size(x);
N = nnfast.numelements(x);
istart = 0;
for i=1:S
  [dummy1,yind,vind] = intersect(istart+(1:N(i)),ind);
  for ts=1:TS
    x{i,ts}(yind,:) = v{1,ts}(vind,:);
  end
  istart = istart + N(i);
end
