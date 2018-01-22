function fcns = subfcn_cache(net)

% Copyright 2012 The MathWorks, Inc.

persistent FCNS;
if nargin == 0
  FCNS = [];
else
  if isempty(FCNS)
    FCNS = nn7.subfcns(net);
  end
  fcns = FCNS;
end
