function [calcMode,err] = options2Mode(net,nameValuePairs)

% Copyright 2012 The MathWorks, Inc.

% useParallel:
%   'no' (default)
%   'yes' (fallback to 'no' if (matlabpool('size') == 0)

% useGPU
%   'no' (default)
%   'yes' (fallback to 'no' on each worker without a unique GPU)
%   'only' (only GPU workers used, all workers fallback to 'no' if no GPUs)

calcMode = [];
err = '';

% Default options
options.precision = 'double';
options.direction = 'default';
options.reduction = net.efficiency.memoryReduction;
options.useGPU = 'no';
options.useParallel = 'no';
options.showResources = 'no';
options.direction = 'default';

% Override options
optionNames = lower(fieldnames(options));
for i=1:2:numel(nameValuePairs)
  name = nameValuePairs{i};
  value = nameValuePairs{i+1};
  j = nnstring.match(lower(name),optionNames);
  if isempty(j)
    err = ['The string ''' name ''' is not a recognized option name.'];
    return
  end
  options.(name) = value;
end
  
% Check that options have legal values
if ~ischar(options.precision) || (size(options.precision,1) ~= 1) || ...
  isempty(nnstring.match(options.precision,{'single','double'}))
  err = 'Option ''precision'' must be either ''single'' or ''double''.';
  return
end
if ~ischar(options.direction) || (size(options.direction,1) ~= 1) || ...
  isempty(nnstring.match(options.direction,{'default','forward','backward'}))
  err = 'Option ''direction'' must be ''default'', ''forward'' or ''backward''.';
  return
end
if ~ischar(options.useParallel) || (size(options.useParallel,1) ~= 1) || ...
  isempty(nnstring.match(options.useParallel,{'no','yes','always'}))
  err = 'Option ''useParallel'' must be either ''no'' or ''yes''.';
  return
end
if ~ischar(options.useGPU) || (size(options.useGPU,1) ~= 1) || ...
  isempty(nnstring.match(options.useGPU,{'no','yes','only'}))
  err = 'Option ''useGPU'' must be either ''no'', ''yes'' or ''only''.';
  return
end
if ~isscalar(options.reduction) || ~isnumeric(options.reduction) || ...
    (options.reduction < 1) || (options.reduction ~= floor(options.reduction))
  err = 'Memory reduction must be an integer of 1 or greater.';
  return;
end
if ~ischar(options.showResources) || (size(options.showResources,1) ~= 1) || ...
  isempty(nnstring.match(options.showResources,{'yes','no'}))
  err = 'Option ''showResources'' must be either ''yes'' or ''no''.';
  return
end

% Pick the calculation mode
if strcmp(options.useParallel,'yes') && ~strcmp(options.useGPU,'no')
  calcMode = nnParallel('subcalc',nnGPU('precision',options.precision),...
    'onlyGPUs',strcmp(options.useGPU,'only'),'direction',options.direction);
elseif strcmp(options.useParallel,'yes')
  calcMode = nnParallel('subcalc',MexOrMATLAB(net,options,true),'direction',options.direction);
elseif ~strcmp(options.useGPU,'no')
  calcMode = nnGPU('precision',options.precision);
else
  calcMode = MexOrMATLAB(net,options,false);
end

% Save showResources setting
calcMode.showResources = strcmp(options.showResources,'yes');

function calcMode = MexOrMATLAB(net,options,isParallel)
calcMode = nncalc.defaultMode(net,[],isParallel);
calcMode.hints.direction = options.direction;
if (options.reduction > 1) && ~strcmp(calcMode.mode,'nnMex')
  calcMode = nnMemReduc('reduction',options.reduction,'subcalc',calcMode);
end

