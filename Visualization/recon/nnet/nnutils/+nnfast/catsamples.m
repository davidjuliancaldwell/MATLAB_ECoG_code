function y = catsamples(varargin)
%CATSAMPLES_FAST (STRICTNNDATA,STRICTNNDATA,...)

% Copyright 2010 The MathWorks, Inc.

if nargin == 0
  y = {};
  return;
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

q = zeros(1,nargin);
for i=1:nargin
  q(i) = nnfast.numsamples(varargin{i});
end
Q = sum(q);
N = nnfast.numelements(varargin{1});

y = cell(S,TS);
for i=1:S
  for ts=1:TS
    yi = zeros(N(i),Q);
    pos = 0;
    for j=1:nargin
      yi(:,pos+(1:q(j))) = varargin{j}{i,ts};
      pos = pos + q(j);
    end
    y{i,ts} = yi;
  end
end
