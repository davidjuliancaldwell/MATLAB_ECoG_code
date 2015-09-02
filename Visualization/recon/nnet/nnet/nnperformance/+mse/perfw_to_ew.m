function ew = perfw2ew(perfw)
%MSE.PERFW2EW

% Copyright 2012 The MathWorks, Inc.

if iscell(perfw)
  ew = cell(size(perfw));
  for i=1:numel(ew)
    ew{i} = sqrt(perfw{i});
  end
else
  ew = sqrt(perfw);
end
