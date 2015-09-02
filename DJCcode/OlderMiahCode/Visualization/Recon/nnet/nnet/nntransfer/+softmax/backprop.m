function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(da);
dn = zeros(S,Q,N);
for i=1:S
  ai = a(i,:);
  for j=1:S
    aj = a(j,:);
    if (j==i)
      dn(i,:,:) = dn(i,:,:) + bsxfun(@times,ai.*(1-ai),da(i,:,:));
    else
      dn(j,:,:) = dn(j,:,:) - bsxfun(@times,ai.*aj,da(i,:,:));
    end
  end
end
