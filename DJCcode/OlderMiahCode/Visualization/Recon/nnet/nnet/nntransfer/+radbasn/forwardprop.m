function da = forwardprop(dn,n,a,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dn);

da = zeros(S,Q,N);
for q=1:Q
  nq = n(:,q); % Sx1
  aq = a(:,q); % Sx1
  anq = aq.*nq; % Sx1
  dq = 2*(bsxfun(@times,anq,aq') - diag(anq)); % SxS
  
  dnq = dn(:,q,:);
  da(:,q,:) = reshape(sum(bsxfun(@times,dq,dnq),1),S,1,N);
end
