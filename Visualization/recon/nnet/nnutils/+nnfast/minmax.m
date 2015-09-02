function mm = minmax(x)
%MINMAX_FAST (STRICTNNDATA) => {1xS}{2xNi}

% Copyright 2010 The MathWorks, Inc.

[r,c] = size(x);
mm = cell(r,1);
for i=1:r
  xi1 = x{i,1};
  mini = min(xi1,[],2);
  maxi = max(xi1,[],2);
  for j=2:c
    xij = x{i,j};
    mini = min(mini,min(xij,[],2));
    maxi = max(maxi,max(xij,[],2));
  end
  mini(isnan(mini)) = -inf;
  maxi(isnan(maxi)) = inf;
  mmi = [mini maxi];
  if size(mmi,2) == 0
    mmi = repmat([-inf inf],size(mmi,1),1);
  end
  mm{i} = mmi;
end
