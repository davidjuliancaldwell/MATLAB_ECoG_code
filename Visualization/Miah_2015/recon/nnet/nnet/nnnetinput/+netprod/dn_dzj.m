function d = dn_dzj(j,z,n,param)

% Copyright 2012 The MathWorks, Inc.

if length(z) == 1
  d = ones(size(n));
else
  zj = z{j};
  if all(all(zj ~= 0))
    d = n ./ zj;
  else
    d = ones(size(n));
    for i=1:length(z)
      if (i ~= j)
        d = d .* z{i};
      end
    end
  end
end
