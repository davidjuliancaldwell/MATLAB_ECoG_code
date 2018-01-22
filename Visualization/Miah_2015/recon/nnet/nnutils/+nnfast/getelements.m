function y = getelements(x,ind)
%GETELEMENTS_FAST (STRICTNNDATA,IND)

% Copyright 2010 The MathWorks, Inc.

numind = length(ind);
[N,Q,TS,S] = nnfast.nnsize(x);
sumN = sum(N);
if (length(ind)==sumN) && all(ind == 1:sumN)
  y = cell(1,TS);
  for ts=1:TS, y{ts} = cat(1,x{:,ts}); end
else
  y = {zeros(numind,Q)};
  y = y(1,ones(1,TS));
  istart = 0;
  for i=1:S
    [~,xind,yind] = intersect(istart+(1:N(i)),ind);
    if ~isempty(xind)
      for ts=1:TS
        y{1,ts}(yind,:) = x{i,ts}(xind,:);
      end
    end
    istart = istart + N(i);
  end
end
