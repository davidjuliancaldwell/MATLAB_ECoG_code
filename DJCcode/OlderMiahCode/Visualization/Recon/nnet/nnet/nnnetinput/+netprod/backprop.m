function dz = backprop(dn,j,z,n,param)
%NETSUM.BACKPROP

% Copyright 2012 The MathWorks, Inc.

if length(z) == 1
  dz = dn;
else
  zj = z{j};
  if all(all(zj ~= 0))
    dz = bsxfun(@times,dn,n ./ z{j});
  else
    dz = dn;
    for i=1:numel(z)
      if (i ~= j)
        dz = bsxfun(@times,dz,z{i});
      end
    end
  end
end
