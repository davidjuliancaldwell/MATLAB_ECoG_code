function z = apply(w,p,param)

% Copyright 2012 The MathWorks, Inc.

[R,Q] = size(p);
M = length(w);
S = R-M+1;
z = zeros(S,Q);
pframe = 0:(M-1);
for i=1:S,
 z(i,:)= w'*p(i+pframe,:);
end
