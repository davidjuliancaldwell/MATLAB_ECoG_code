function dn = forwardprop(dz,j,z,n,param)
%NETSUM.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

if length(z) == 1
  dn = dz;
else
  zj = z{j};
  if all(all(zj ~= 0))
    dn = bsxfun(@times,dz,n ./ zj);
  else
    dn = dz;
    for i=1:numel(z)
      if (i ~= j)
        dn = bsxfun(@times,dn,z{i});
      end
    end
  end
end
