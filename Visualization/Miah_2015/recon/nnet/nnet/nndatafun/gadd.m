function c = gadd(a,b)
%GADD Generalized addition.
%
% <a href="matlab:doc gadd">gadd</a>(a,b) returns a + b, supporting built in data behavior, as well as
% generalized behavior such as element-by-element and recursive addition
% of cell arrays and matrices, and extending dimensions of size 1 in either
% argument to match the respective dimension of the other argument.
%
% Here are examples of adding with generalized behavior:
%
%   <a href="matlab:doc gadd">gadd</a>([1 2 3; 4 5 6],[10;20])
%   <a href="matlab:doc gadd">gadd</a>({1 2; 3 4},{1 3; 5 2})
%   <a href="matlab:doc gadd">gadd</a>({1 2 3 4},{10;20;30})
%    
% See also GSUBTRACT, GMULTIPLY, GDIVIDE, GNEGATE.

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 2, error(message('nnet:Args:NotEnough')); end

if (isnumeric(a) && isnumeric(b))
  c = bsxfun(@plus,a,b);
elseif iscell(a) && iscell(b)
  c = calc_cell(a,b);
else
  c = calc_general(a,b);
end

function c = calc_general(a,b)
if iscell(a)
  if iscell(b)
    c = calc_cell(a,b);
  else
    c = calc_general(a,{b});
  end
elseif iscell(b)
  c = calc_general({a},b);
elseif isnumeric(a) || islogical(a) || ischar(a)
  if isnumeric(b) || islogical(b) || ischar(b)
    c = bsxfun(@plus,a,b);
  else
    c1 = class(a);
    c2 = class(b);
    nnerr.throw('Args',['Cannot combine values of class ' c1 ' with ' c2 '.']);
  end
elseif isa(b,class(a))
  c = a + b;
else
  c1 = class(a);
  c2 = class(b);
  nnerr.throw('Args',['Cannot combine values of class ' c1 ' and ' c2 '.']);
end

function c = calc_cell(a,b)
  
% Argument with One Element
if numel(b) == 1
  b = b{1};
  c = cell(size(a));
  for i=1:numel(a), c{i} = calc_general(a{i},b); end
  return
elseif numel(a) == 1
  a = a{1};
  c = cell(size(b));
  for i=1:numel(b), c{i} = calc_general(b{i},a); end
  return;
end

% Argument Sizes Match
asize = size(a);
bsize = size(b);
adims = length(asize);
bdims = length(bsize);
if (adims==bdims) && all(asize==bsize)
  c = cell(asize);
  for i=1:prod(asize)
    c{i} = gadd(a{i},b{i});
  end
  return
end

% Argument Sizes are Incompatible
while (asize(end)==1), asize(end) = []; end
while (bsize(end)==1), bsize(end) = []; end
adims = length(asize);
bdims = length(bsize);
cdims = max([adims bdims]);
if (adims < cdims), asize = [asize ones(1,cdims-adims)]; end
if (bdims < cdims), bsize = [bsize ones(1,cdims-bdims)]; end
match = all((asize==bsize) | (asize==1) | (bsize==1));
if ~match, error(message('nnet:Math:CellDimMismatch')); end

% Allocate C
csize = asize;
i = find(asize==1);
csize(i) = bsize(i);
c = cell([csize 1]);

% Argument Sizes are Compatible, Empty Result
numC = prod(csize);
if (numC == 0), return, end

% Argument Sizes are Compatible, Non-Empty Result
aMask = asize > 1;
bMask = bsize > 1;
aBase = [1 cumprod(asize(1:(end-1)))]';
bBase = [1 cumprod(bsize(1:(end-1)))]';
cBase = [1 cumprod(csize(1:(end-1)))]';
cSizeMinus1 = csize-1;
ic = [-1 zeros(1,cdims-1)];
for i=1:numC
  ic = inc_complex_num0(ic,cSizeMinus1);
  iic = 1 + ic * cBase;
  iia = 1 + (ic .* aMask) * aBase;
  iib = 1 + (ic .* bMask) * bBase;
  c{iic} = calc_general(a{iia},b{iib});
end


function n = inc_complex_num0(n,baseMinus1)
i = 1;
while n(i) == baseMinus1(i)
  n(i) = 0;
  i = i + 1;
end
n(i) = n(i) + 1;

