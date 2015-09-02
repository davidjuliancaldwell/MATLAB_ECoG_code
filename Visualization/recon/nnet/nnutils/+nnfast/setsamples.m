function x = setsamples(x,ind,v)
%SETSAMPLES_FAST (STRICTNNDATA,INDICES,STRICTNNDATA) => STRICTNNDATA

% Copyright 2010 The MathWorks, Inc.

[S,TS] = size(x);
for i=1:S
  for ts=1:TS
    x{i,ts} = x{i,ts};
    x{i,ts}(:,ind) = v{i,ts};
  end
end
