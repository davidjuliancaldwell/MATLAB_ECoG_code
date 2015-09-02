function m=resizem(m,r,c)
%RESIZEM Resize matrix by truncating or adding zeros.

% Copyright 2010 The MathWorks, Inc.

if nargin == 1, [r,c] = size(m); end
if nargin == 2, c=r(2); r=r(1); end

[R,C] = size(m);
if (r < R)
  m = m(1:r,:);
elseif (r > R)
  m = [m; zeros(r-R,C)];
end
if (c < C)
  m = m(:,1:c);
elseif (c > C)
  m = [m zeros(r,c-C)];
end
