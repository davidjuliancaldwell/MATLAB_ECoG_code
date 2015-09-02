function y = catelements(varargin)
%CATELEMENTS_FAST (STRICTNNDATA,STRICTNNDATA,...)

% Copyright 2010 The MathWorks, Inc.

if nargin == 0
  y = {};
  return
end

if nargin == 1
  y = varargin{1};
  return
end

[S,TS] = size(varargin{1});
if (S==0) || (TS==0)
  y = varargin{1};
  return
end

Q = size(varargin{1}{1},2);
n = zeros(S,nargin);
for i=1:nargin
  n(:,i) = nnfast.numelements(varargin{i});
end
N = sum(n,2);

y = cell(S,TS);
for i=1:S
  for ts=1:TS
    yi = zeros(N(i),Q);
    pos = 0;
    for j=1:nargin
      yi(pos+(1:n(i,j)),:) = varargin{j}{i,ts};
      pos = pos + n(i,j);
    end
    y{i,ts} = yi;
  end
end
