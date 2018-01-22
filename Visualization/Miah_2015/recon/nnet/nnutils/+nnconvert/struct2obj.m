function x = struct2obj(x,s)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, s = x; end
fn = fieldnames(x);
for i=1:length(fn)
  fni = fn{i};
  v = s.(fni);
  if strcmp(fni,'gradientFcn') || strcmp(fni,'gradientParam')
    % NNET 6.0 Compatibility
    % do nothing
  elseif strcmp(fni,'efficiency') % TODO - nnEfficiency object?
    % Nothing
  elseif nnstring.ends(fni,'Fcn')
    lastFcn = v;
  elseif nnstring.ends(fni,'Fcns')
    lastFcn = v;
  elseif nnstring.ends(fni,'Param') || nnstring.ends(fni,'Params')
    v = nn_cellstruct2param(lastFcn,v);
  elseif nnstring.ends(fni,'Settings')
    v = nn_cellstruct2settings(lastFcn,v);
  elseif strcmp(fni,'inputs')
    v = nn_cellstruct2obj(v,'nnetInput');
  elseif strcmp(fni,'layers')
    v = nn_cellstruct2obj(v,'nnetLayer');
  elseif strcmp(fni,'outputs')
    v = nn_cellstruct2obj(v,'nnetOutput');
  elseif strcmp(fni,'biases')
    v = nn_cellstruct2obj(v,'nnetBias');
  elseif strcmp(fni,'inputWeights')
    v = nn_cellstruct2obj(v,'nnetWeight');
  elseif strcmp(fni,'layerWeights')
    v = nn_cellstruct2obj(v,'nnetWeight');
  end
  x.(fni) = v;
end

function v = nn_cellstruct2obj(v,type)
if isstruct(v)
  v = feval(type,v);
elseif iscell(v)
  for i=1:numel(v)
    vi = v{i};
    if isstruct(vi)
      v{i} = feval(type,vi);
    end
  end
elseif isobject(v)
  % do nothing
else
  error(message('nnet:General:UnrecCondition'));
end

function v = nn_cellstruct2param(f,v)
if isa(v,'nnetParam')
  % Do nothing
elseif isstruct(v)
  v = nnetParam(f,v);
elseif iscell(v)
  for i=1:numel(v)
    v{i} = nn_cellstruct2param(f{i},v{i});
  end
end

function v = nn_cellstruct2settings(f,v)
if isa(v,'nnetSetting')
  % Do nothing
elseif isempty(v)
  v = [];
elseif isstruct(v)
  v = nnetSetting(f,v);
elseif iscell(v)
  for i=1:numel(v)
    v{i} = nn_cellstruct2settings(f{i},v{i});
  end
end
