function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dn);
da = zeros(S,Q,N);
for i=1:S
  ai = a(i,:);
  for j=1:S
    aj = a(j,:);
    if (j==i)
      da(i,:,:) = da(i,:,:) + bsxfun(@times,ai .* (1-ai),dn(i,:,:));
    else
      da(j,:,:) = da(j,:,:) - bsxfun(@times,ai .* aj,dn(i,:,:));
    end
  end
end
